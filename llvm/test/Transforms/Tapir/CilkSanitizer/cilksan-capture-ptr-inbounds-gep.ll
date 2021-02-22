; Check that Cilksan properly handles pointers that are constant-GEP
; expressions.
;
; RUN: opt < %s -csan -S -o - | FileCheck %s
; RUN: opt < %s -passes='cilksan' -S -o - | FileCheck %s

target datalayout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128"
target triple = "x86_64-unknown-linux-gnu"

%"class.std::ios_base::Init.0.311.618.925.1232.1539.1846" = type { i8 }
%struct.timer.5.316.623.930.1237.1544.1851 = type { double, double, i8, %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %struct.timezone.4.315.622.929.1236.1543.1850 }
%"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849" = type { %"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider.1.312.619.926.1233.1540.1847", i64, %union.anon.2.313.620.927.1234.1541.1848 }
%"struct.std::__cxx11::basic_string<char, std::char_traits<char>, std::allocator<char> >::_Alloc_hider.1.312.619.926.1233.1540.1847" = type { i8* }
%union.anon.2.313.620.927.1234.1541.1848 = type { i64, [8 x i8] }
%struct.timezone.4.315.622.929.1236.1543.1850 = type { i32, i32 }
%"class.std::basic_ostream.20.331.638.945.1252.1559.1866" = type { i32 (...)**, %"class.std::basic_ios.19.330.637.944.1251.1558.1865" }
%"class.std::basic_ios.19.330.637.944.1251.1558.1865" = type { %"class.std::ios_base.11.322.629.936.1243.1550.1857", %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"*, i8, i8, %"class.std::basic_streambuf.12.323.630.937.1244.1551.1858"*, %"class.std::ctype.16.327.634.941.1248.1555.1862"*, %"class.std::num_put.17.328.635.942.1249.1556.1863"*, %"class.std::num_get.18.329.636.943.1250.1557.1864"* }
%"class.std::ios_base.11.322.629.936.1243.1550.1857" = type { i32 (...)**, i64, i64, i32, i32, i32, %"struct.std::ios_base::_Callback_list.6.317.624.931.1238.1545.1852"*, %"struct.std::ios_base::_Words.7.318.625.932.1239.1546.1853", [8 x %"struct.std::ios_base::_Words.7.318.625.932.1239.1546.1853"], i32, %"struct.std::ios_base::_Words.7.318.625.932.1239.1546.1853"*, %"class.std::locale.10.321.628.935.1242.1549.1856" }
%"struct.std::ios_base::_Callback_list.6.317.624.931.1238.1545.1852" = type { %"struct.std::ios_base::_Callback_list.6.317.624.931.1238.1545.1852"*, void (i32, %"class.std::ios_base.11.322.629.936.1243.1550.1857"*, i32)*, i32, i32 }
%"struct.std::ios_base::_Words.7.318.625.932.1239.1546.1853" = type { i8*, i64 }
%"class.std::locale.10.321.628.935.1242.1549.1856" = type { %"class.std::locale::_Impl.9.320.627.934.1241.1548.1855"* }
%"class.std::locale::_Impl.9.320.627.934.1241.1548.1855" = type { i32, %"class.std::locale::facet.8.319.626.933.1240.1547.1854"**, i64, %"class.std::locale::facet.8.319.626.933.1240.1547.1854"**, i8** }
%"class.std::locale::facet.8.319.626.933.1240.1547.1854" = type <{ i32 (...)**, i32, [4 x i8] }>
%"class.std::basic_streambuf.12.323.630.937.1244.1551.1858" = type { i32 (...)**, i8*, i8*, i8*, i8*, i8*, i8*, %"class.std::locale.10.321.628.935.1242.1549.1856" }
%"class.std::ctype.16.327.634.941.1248.1555.1862" = type <{ %"class.std::locale::facet.base.13.324.631.938.1245.1552.1859", [4 x i8], %struct.__locale_struct.15.326.633.940.1247.1554.1861*, i8, [7 x i8], i32*, i32*, i16*, i8, [256 x i8], [256 x i8], i8, [6 x i8] }>
%"class.std::locale::facet.base.13.324.631.938.1245.1552.1859" = type <{ i32 (...)**, i32 }>
%struct.__locale_struct.15.326.633.940.1247.1554.1861 = type { [13 x %struct.__locale_data.14.325.632.939.1246.1553.1860*], i16*, i32*, i32*, [13 x i8*] }
%struct.__locale_data.14.325.632.939.1246.1553.1860 = type opaque
%"class.std::num_put.17.328.635.942.1249.1556.1863" = type { %"class.std::locale::facet.base.13.324.631.938.1245.1552.1859", [4 x i8] }
%"class.std::num_get.18.329.636.943.1250.1557.1864" = type { %"class.std::locale::facet.base.13.324.631.938.1245.1552.1859", [4 x i8] }
%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882" = type { i8, [63 x i8], %"class.parlay::concurrent_stack.28.339.646.953.1260.1567.1874", %"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, i64, i64, i64, %"struct.std::atomic.35.346.653.960.1267.1574.1881", i64, [16 x i8] }
%"class.parlay::concurrent_stack.28.339.646.953.1260.1567.1874" = type { %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack.27.338.645.952.1259.1566.1873", %"class.parlay::concurrent_stack<char *>::locking_concurrent_stack.27.338.645.952.1259.1566.1873" }
%"class.parlay::concurrent_stack<char *>::locking_concurrent_stack.27.338.645.952.1259.1566.1873" = type { %"struct.parlay::concurrent_stack<char *>::Node.21.332.639.946.1253.1560.1867"*, %"class.std::mutex.26.337.644.951.1258.1565.1872", [16 x i8] }
%"struct.parlay::concurrent_stack<char *>::Node.21.332.639.946.1253.1560.1867" = type { i8*, %"struct.parlay::concurrent_stack<char *>::Node.21.332.639.946.1253.1560.1867"*, i64 }
%"class.std::mutex.26.337.644.951.1258.1565.1872" = type { %"class.std::__mutex_base.25.336.643.950.1257.1564.1871" }
%"class.std::__mutex_base.25.336.643.950.1257.1564.1871" = type { %union.pthread_mutex_t.24.335.642.949.1256.1563.1870 }
%union.pthread_mutex_t.24.335.642.949.1256.1563.1870 = type { %struct.__pthread_mutex_s.23.334.641.948.1255.1562.1869 }
%struct.__pthread_mutex_s.23.334.641.948.1255.1562.1869 = type { i32, i32, i32, i32, i32, i16, i16, %struct.__pthread_internal_list.22.333.640.947.1254.1561.1868 }
%struct.__pthread_internal_list.22.333.640.947.1254.1561.1868 = type { %struct.__pthread_internal_list.22.333.640.947.1254.1561.1868*, %struct.__pthread_internal_list.22.333.640.947.1254.1561.1868* }
%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878" = type { %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack.31.342.649.956.1263.1570.1877", %"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack.31.342.649.956.1263.1570.1877" }
%"class.parlay::concurrent_stack<parlay::block_allocator::block *>::locking_concurrent_stack.31.342.649.956.1263.1570.1877" = type { %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node.30.341.648.955.1262.1569.1876"*, %"class.std::mutex.26.337.644.951.1258.1565.1872", [16 x i8] }
%"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node.30.341.648.955.1262.1569.1876" = type { %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::concurrent_stack<parlay::block_allocator::block *>::Node.30.341.648.955.1262.1569.1876"*, i64 }
%"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875" = type { %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* }
%"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879" = type { i64, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, [256 x i8], [40 x i8] }
%"struct.std::atomic.35.346.653.960.1267.1574.1881" = type { %"struct.std::__atomic_base.34.345.652.959.1266.1573.1880" }
%"struct.std::__atomic_base.34.345.652.959.1266.1573.1880" = type { i64 }
%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896" = type { i64, i64, i64, i64, %"struct.std::atomic.35.346.653.960.1267.1574.1881", %"struct.std::atomic.35.346.653.960.1267.1574.1881", %"class.std::unique_ptr.81.45.356.663.970.1277.1584.1891", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*, %"class.std::vector.90.49.360.667.974.1281.1588.1895", i64 }
%"class.std::unique_ptr.81.45.356.663.970.1277.1584.1891" = type { %"struct.std::__uniq_ptr_data.82.44.355.662.969.1276.1583.1890" }
%"struct.std::__uniq_ptr_data.82.44.355.662.969.1276.1583.1890" = type { %"class.std::__uniq_ptr_impl.83.43.354.661.968.1275.1582.1889" }
%"class.std::__uniq_ptr_impl.83.43.354.661.968.1275.1582.1889" = type { %"class.std::tuple.84.42.353.660.967.1274.1581.1888" }
%"class.std::tuple.84.42.353.660.967.1274.1581.1888" = type { %"struct.std::_Tuple_impl.85.41.352.659.966.1273.1580.1887" }
%"struct.std::_Tuple_impl.85.41.352.659.966.1273.1580.1887" = type { %"struct.std::_Head_base.88.40.351.658.965.1272.1579.1886" }
%"struct.std::_Head_base.88.40.351.658.965.1272.1579.1886" = type { %"class.parlay::concurrent_stack.89.39.350.657.964.1271.1578.1885"* }
%"class.parlay::concurrent_stack.89.39.350.657.964.1271.1578.1885" = type { %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack.38.349.656.963.1270.1577.1884", %"class.parlay::concurrent_stack<void *>::locking_concurrent_stack.38.349.656.963.1270.1577.1884" }
%"class.parlay::concurrent_stack<void *>::locking_concurrent_stack.38.349.656.963.1270.1577.1884" = type { %"struct.parlay::concurrent_stack<void *>::Node.37.348.655.962.1269.1576.1883"*, %"class.std::mutex.26.337.644.951.1258.1565.1872", [16 x i8] }
%"struct.parlay::concurrent_stack<void *>::Node.37.348.655.962.1269.1576.1883" = type { i8*, %"struct.parlay::concurrent_stack<void *>::Node.37.348.655.962.1269.1576.1883"*, i64 }
%"class.std::vector.90.49.360.667.974.1281.1588.1895" = type { %"struct.std::_Vector_base.91.48.359.666.973.1280.1587.1894" }
%"struct.std::_Vector_base.91.48.359.666.973.1280.1587.1894" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl.47.358.665.972.1279.1586.1893" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl.47.358.665.972.1279.1586.1893" = type { %"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data.46.357.664.971.1278.1585.1892" }
%"struct.std::_Vector_base<unsigned long, std::allocator<unsigned long> >::_Vector_impl_data.46.357.664.971.1278.1585.1892" = type { i64*, i64*, i64* }
%struct.vertex.52.363.670.977.1284.1591.1898 = type { %class.point2d.51.362.669.976.1283.1590.1897, %struct.triangle.53.364.671.978.1285.1592.1899*, %struct.triangle.53.364.671.978.1285.1592.1899*, i32, i32, i64 }
%class.point2d.51.362.669.976.1283.1590.1897 = type { double, double }
%struct.triangle.53.364.671.978.1285.1592.1899 = type { [3 x %struct.triangle.53.364.671.978.1285.1592.1899*], [3 x %struct.vertex.52.363.670.977.1284.1591.1898*], i64, i8, i8 }
%struct.Qs.63.374.681.988.1295.1602.1909 = type { %"class.std::vector.57.368.675.982.1289.1596.1903", %"class.std::vector.3.62.373.680.987.1294.1601.1908" }
%"class.std::vector.57.368.675.982.1289.1596.1903" = type { %"struct.std::_Vector_base.56.367.674.981.1288.1595.1902" }
%"struct.std::_Vector_base.56.367.674.981.1288.1595.1902" = type { %"struct.std::_Vector_base<vertex<point2d<double> > *, std::allocator<vertex<point2d<double> > *> >::_Vector_impl.55.366.673.980.1287.1594.1901" }
%"struct.std::_Vector_base<vertex<point2d<double> > *, std::allocator<vertex<point2d<double> > *> >::_Vector_impl.55.366.673.980.1287.1594.1901" = type { %"struct.std::_Vector_base<vertex<point2d<double> > *, std::allocator<vertex<point2d<double> > *> >::_Vector_impl_data.54.365.672.979.1286.1593.1900" }
%"struct.std::_Vector_base<vertex<point2d<double> > *, std::allocator<vertex<point2d<double> > *> >::_Vector_impl_data.54.365.672.979.1286.1593.1900" = type { %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898** }
%"class.std::vector.3.62.373.680.987.1294.1601.1908" = type { %"struct.std::_Vector_base.4.61.372.679.986.1293.1600.1907" }
%"struct.std::_Vector_base.4.61.372.679.986.1293.1600.1907" = type { %"struct.std::_Vector_base<simplex<point2d<double> >, std::allocator<simplex<point2d<double> > > >::_Vector_impl.60.371.678.985.1292.1599.1906" }
%"struct.std::_Vector_base<simplex<point2d<double> >, std::allocator<simplex<point2d<double> > > >::_Vector_impl.60.371.678.985.1292.1599.1906" = type { %"struct.std::_Vector_base<simplex<point2d<double> >, std::allocator<simplex<point2d<double> > > >::_Vector_impl_data.59.370.677.984.1291.1598.1905" }
%"struct.std::_Vector_base<simplex<point2d<double> >, std::allocator<simplex<point2d<double> > > >::_Vector_impl_data.59.370.677.984.1291.1598.1905" = type { %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904* }
%struct.simplex.58.369.676.983.1290.1597.1904 = type <{ %struct.triangle.53.364.671.978.1285.1592.1899*, i32, i8, [3 x i8] }>
%"class.parlay::sequence.72.383.690.997.1304.1611.1918" = type { %"struct.parlay::_sequence_base.71.382.689.996.1303.1610.1917" }
%"struct.parlay::_sequence_base.71.382.689.996.1303.1610.1917" = type { %"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl.70.381.688.995.1302.1609.1916" }
%"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl.70.381.688.995.1302.1609.1916" = type { %"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::_data_impl.69.380.687.994.1301.1608.1915" }
%"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::_data_impl.69.380.687.994.1301.1608.1915" = type { %union.anon.8.68.379.686.993.1300.1607.1914, i8 }
%union.anon.8.68.379.686.993.1300.1607.1914 = type { %"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::long_seq.67.378.685.992.1299.1606.1913" }
%"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::long_seq.67.378.685.992.1299.1606.1913" = type <{ %"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::capacitated_buffer.66.377.684.991.1298.1605.1912", [6 x i8] }>
%"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::capacitated_buffer.66.377.684.991.1298.1605.1912" = type { %"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.65.376.683.990.1297.1604.1911"* }
%"struct.parlay::_sequence_base<triangle<point2d<double> >, parlay::allocator<triangle<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.65.376.683.990.1297.1604.1911" = type { i64, %union.anon.68.64.375.682.989.1296.1603.1910 }
%union.anon.68.64.375.682.989.1296.1603.1910 = type { [1 x i8], [7 x i8] }
%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927" = type { %"struct.parlay::_sequence_base.10.80.391.698.1005.1312.1619.1926" }
%"struct.parlay::_sequence_base.10.80.391.698.1005.1312.1619.1926" = type { %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl.79.390.697.1004.1311.1618.1925" }
%"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl.79.390.697.1004.1311.1618.1925" = type { %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::_data_impl.78.389.696.1003.1310.1617.1924" }
%"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::_data_impl.78.389.696.1003.1310.1617.1924" = type { %union.anon.13.77.388.695.1002.1309.1616.1923, i8 }
%union.anon.13.77.388.695.1002.1309.1616.1923 = type { %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::long_seq.76.387.694.1001.1308.1615.1922" }
%"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::long_seq.76.387.694.1001.1308.1615.1922" = type <{ %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer.75.386.693.1000.1307.1614.1921", [6 x i8] }>
%"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer.75.386.693.1000.1307.1614.1921" = type { %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* }
%"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920" = type { i64, %union.anon.66.73.384.691.998.1305.1612.1919 }
%union.anon.66.73.384.691.998.1305.1612.1919 = type { [1 x i8], [7 x i8] }
%"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936" = type { %"struct.parlay::_sequence_base.15.89.400.707.1014.1321.1628.1935" }
%"struct.parlay::_sequence_base.15.89.400.707.1014.1321.1628.1935" = type { %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl.88.399.706.1013.1320.1627.1934" }
%"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl.88.399.706.1013.1320.1627.1934" = type { %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::_data_impl.87.398.705.1012.1319.1626.1933" }
%"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::_data_impl.87.398.705.1012.1319.1626.1933" = type { %union.anon.18.86.397.704.1011.1318.1625.1932, i8 }
%union.anon.18.86.397.704.1011.1318.1625.1932 = type { %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::long_seq.85.396.703.1010.1317.1624.1931" }
%"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::long_seq.85.396.703.1010.1317.1624.1931" = type <{ %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::capacitated_buffer.84.395.702.1009.1316.1623.1930", [6 x i8] }>
%"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::capacitated_buffer.84.395.702.1009.1316.1623.1930" = type { %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::capacitated_buffer::header.83.394.701.1008.1315.1622.1929"* }
%"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl::capacitated_buffer::header.83.394.701.1008.1315.1622.1929" = type { i64, %union.anon.69.82.393.700.1007.1314.1621.1928 }
%union.anon.69.82.393.700.1007.1314.1621.1928 = type { [1 x i8], [7 x i8] }
%"class.parlay::sequence.19.99.410.717.1024.1331.1638.1945" = type { %"struct.parlay::_sequence_base.20.98.409.716.1023.1330.1637.1944" }
%"struct.parlay::_sequence_base.20.98.409.716.1023.1330.1637.1944" = type { %"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl.97.408.715.1022.1329.1636.1943" }
%"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl.97.408.715.1022.1329.1636.1943" = type { %"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::_data_impl.96.407.714.1021.1328.1635.1942" }
%"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::_data_impl.96.407.714.1021.1328.1635.1942" = type { %union.anon.23.95.406.713.1020.1327.1634.1941, i8 }
%union.anon.23.95.406.713.1020.1327.1634.1941 = type { %"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::long_seq.94.405.712.1019.1326.1633.1940" }
%"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::long_seq.94.405.712.1019.1326.1633.1940" = type <{ %"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::capacitated_buffer.93.404.711.1018.1325.1632.1939", [6 x i8] }>
%"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::capacitated_buffer.93.404.711.1018.1325.1632.1939" = type { %"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.92.403.710.1017.1324.1631.1938"* }
%"struct.parlay::_sequence_base<vertex<point2d<double> >, parlay::allocator<vertex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.92.403.710.1017.1324.1631.1938" = type { i64, %union.anon.70.91.402.709.1016.1323.1630.1937 }
%union.anon.70.91.402.709.1016.1323.1630.1937 = type { [1 x i8], [7 x i8] }
%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954" = type { %"struct.parlay::_sequence_base.29.107.418.725.1032.1339.1646.1953" }
%"struct.parlay::_sequence_base.29.107.418.725.1032.1339.1646.1953" = type { %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl.106.417.724.1031.1338.1645.1952" }
%"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl.106.417.724.1031.1338.1645.1952" = type { %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::_data_impl.105.416.723.1030.1337.1644.1951" }
%"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::_data_impl.105.416.723.1030.1337.1644.1951" = type { %union.anon.32.104.415.722.1029.1336.1643.1950, i8 }
%union.anon.32.104.415.722.1029.1336.1643.1950 = type { %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::long_seq.103.414.721.1028.1335.1642.1949" }
%"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::long_seq.103.414.721.1028.1335.1642.1949" = type <{ %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer.102.413.720.1027.1334.1641.1948", [6 x i8] }>
%"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer.102.413.720.1027.1334.1641.1948" = type { %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* }
%"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947" = type { i64, %union.anon.71.100.411.718.1025.1332.1639.1946 }
%union.anon.71.100.411.718.1025.1332.1639.1946 = type { [1 x i8], [7 x i8] }
%"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019" = type { i64*, i64* }
%"struct.parlay::addm.154.465.772.1079.1386.1693.2000" = type { i64 }
%"struct.parlay::slice.170.480.787.1094.1401.1708.2015" = type { %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898** }
%class.anon.264.286.593.900.1207.1514.1821.2128 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* }
%"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127" = type { i64, i64, %class.anon.55.284.591.898.1205.1512.1819.2126 }
%class.anon.55.284.591.898.1205.1512.1819.2126 = type { %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* }
%"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036" = type { %"struct.parlay::_sequence_base.39.190.500.807.1114.1421.1728.2035" }
%"struct.parlay::_sequence_base.39.190.500.807.1114.1421.1728.2035" = type { %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl.189.499.806.1113.1420.1727.2034" }
%"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl.189.499.806.1113.1420.1727.2034" = type { %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::_data_impl.188.498.805.1112.1419.1726.2033" }
%"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::_data_impl.188.498.805.1112.1419.1726.2033" = type { %union.anon.42.187.497.804.1111.1418.1725.2032, i8 }
%union.anon.42.187.497.804.1111.1418.1725.2032 = type { %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::long_seq.186.496.803.1110.1417.1724.2031" }
%"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::long_seq.186.496.803.1110.1417.1724.2031" = type <{ %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer.185.495.802.1109.1416.1723.2030", [6 x i8] }>
%"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer.185.495.802.1109.1416.1723.2030" = type { %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* }
%"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029" = type <{ i64, %union.anon.67.183.493.800.1107.1414.1721.2028, [7 x i8] }>
%union.anon.67.183.493.800.1107.1414.1721.2028 = type { [1 x i8] }
%class.anon.265.287.594.901.1208.1515.1822.2129 = type { %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"*, %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"*, %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, i64* }
%"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016" = type { i8*, i8* }
%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962" = type { %"struct.std::__uniq_ptr_data.115.426.733.1040.1347.1654.1961" }
%"struct.std::__uniq_ptr_data.115.426.733.1040.1347.1654.1961" = type { %"class.std::__uniq_ptr_impl.114.425.732.1039.1346.1653.1960" }
%"class.std::__uniq_ptr_impl.114.425.732.1039.1346.1653.1960" = type { %"class.std::tuple.113.424.731.1038.1345.1652.1959" }
%"class.std::tuple.113.424.731.1038.1345.1652.1959" = type { %"struct.std::_Tuple_impl.112.423.730.1037.1344.1651.1958" }
%"struct.std::_Tuple_impl.112.423.730.1037.1344.1651.1958" = type { %"struct.std::_Head_base.51.111.422.729.1036.1343.1650.1957" }
%"struct.std::_Head_base.51.111.422.729.1036.1343.1650.1957" = type { %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* }
%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956" = type <{ i64, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.std::pair.109.420.727.1034.1341.1648.1955", %class.point2d.51.362.669.976.1283.1590.1897, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", i8 }>
%"struct.std::pair.109.420.727.1034.1341.1648.1955" = type { %class.point2d.51.362.669.976.1283.1590.1897, %class.point2d.51.362.669.976.1283.1590.1897 }
%class.anon.262.282.589.896.1203.1510.1817.2124 = type { %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, %struct.vertex.52.363.670.977.1284.1591.1898***, %struct.vertex.52.363.670.977.1284.1591.1898*** }
%"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972" = type { %"struct.parlay::_sequence_base.34.125.436.743.1050.1357.1664.1971" }
%"struct.parlay::_sequence_base.34.125.436.743.1050.1357.1664.1971" = type { %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl.124.435.742.1049.1356.1663.1970" }
%"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl.124.435.742.1049.1356.1663.1970" = type { %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::_data_impl.123.434.741.1048.1355.1662.1969" }
%"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::_data_impl.123.434.741.1048.1355.1662.1969" = type { %union.anon.37.122.433.740.1047.1354.1661.1968, i8 }
%union.anon.37.122.433.740.1047.1354.1661.1968 = type { %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::long_seq.121.432.739.1046.1353.1660.1967" }
%"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::long_seq.121.432.739.1046.1353.1660.1967" = type <{ %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer.120.431.738.1045.1352.1659.1966", [6 x i8] }>
%"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer.120.431.738.1045.1352.1659.1966" = type { %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* }
%"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965" = type { i64, %union.anon.72.118.429.736.1043.1350.1657.1964 }
%union.anon.72.118.429.736.1043.1350.1657.1964 = type { [1 x i8], [7 x i8] }
%"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981" = type { %"struct.parlay::_sequence_base.44.134.445.752.1059.1366.1673.1980" }
%"struct.parlay::_sequence_base.44.134.445.752.1059.1366.1673.1980" = type { %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl.133.444.751.1058.1365.1672.1979" }
%"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl.133.444.751.1058.1365.1672.1979" = type { %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::_data_impl.132.443.750.1057.1364.1671.1978" }
%"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::_data_impl.132.443.750.1057.1364.1671.1978" = type { %union.anon.47.131.442.749.1056.1363.1670.1977, i8 }
%union.anon.47.131.442.749.1056.1363.1670.1977 = type { %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::long_seq.130.441.748.1055.1362.1669.1976" }
%"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::long_seq.130.441.748.1055.1362.1669.1976" = type <{ %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer.129.440.747.1054.1361.1668.1975", [6 x i8] }>
%"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer.129.440.747.1054.1361.1668.1975" = type { %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* }
%"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974" = type { i64, %union.anon.73.127.438.745.1052.1359.1666.1973 }
%union.anon.73.127.438.745.1052.1359.1666.1973 = type { [1 x i8], [7 x i8] }
%class.anon.48.169.479.786.1093.1400.1707.2014 = type { i8 }
%struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963 = type { %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962" }
%class.anon.52.136.447.754.1061.1368.1675.1982 = type { %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, i64*, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, i64*, %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963*, %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"*, %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* }
%struct.triangles.146.457.764.1071.1378.1685.1992 = type { %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936", %"class.parlay::sequence.56.145.456.763.1070.1377.1684.1991" }
%"class.parlay::sequence.56.145.456.763.1070.1377.1684.1991" = type { %"struct.parlay::_sequence_base.57.144.455.762.1069.1376.1683.1990" }
%"struct.parlay::_sequence_base.57.144.455.762.1069.1376.1683.1990" = type { %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl.143.454.761.1068.1375.1682.1989" }
%"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl.143.454.761.1068.1375.1682.1989" = type { %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::_data_impl.142.453.760.1067.1374.1681.1988" }
%"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::_data_impl.142.453.760.1067.1374.1681.1988" = type { %union.anon.60.141.452.759.1066.1373.1680.1987, i8 }
%union.anon.60.141.452.759.1066.1373.1680.1987 = type { %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::long_seq.140.451.758.1065.1372.1679.1986" }
%"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::long_seq.140.451.758.1065.1372.1679.1986" = type <{ %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::capacitated_buffer.139.450.757.1064.1371.1678.1985", [6 x i8] }>
%"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::capacitated_buffer.139.450.757.1064.1371.1678.1985" = type { %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::capacitated_buffer::header.138.449.756.1063.1370.1677.1984"* }
%"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl::capacitated_buffer::header.138.449.756.1063.1370.1677.1984" = type <{ i64, %union.anon.75.137.448.755.1062.1369.1676.1983, [4 x i8] }>
%union.anon.75.137.448.755.1062.1369.1676.1983 = type { [1 x i8], [3 x i8] }
%"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993" = type { i64*, i64* }
%"class.std::invalid_argument.152.463.770.1077.1384.1691.1998" = type { %"class.std::logic_error.151.462.769.1076.1383.1690.1997" }
%"class.std::logic_error.151.462.769.1076.1383.1690.1997" = type { %"class.std::exception.148.459.766.1073.1380.1687.1994", %"struct.std::__cow_string.150.461.768.1075.1382.1689.1996" }
%"class.std::exception.148.459.766.1073.1380.1687.1994" = type { i32 (...)** }
%"struct.std::__cow_string.150.461.768.1075.1382.1689.1996" = type { %union.anon.95.149.460.767.1074.1381.1688.1995 }
%union.anon.95.149.460.767.1074.1381.1688.1995 = type { i8* }
%"class.std::bad_alloc.153.464.771.1078.1385.1692.1999" = type { %"class.std::exception.148.459.766.1073.1380.1687.1994" }
%class.anon.106.156.467.774.1081.1388.1695.2002 = type { i64*, i64*, %class.anon.77.155.466.773.1080.1387.1694.2001* }
%class.anon.77.155.466.773.1080.1387.1694.2001 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993"*, %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* }
%class.anon.108.158.469.776.1083.1390.1697.2004 = type { i64*, i64*, %class.anon.107.157.468.775.1082.1389.1696.2003* }
%class.anon.107.157.468.775.1082.1389.1696.2003 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* }
%"struct.parlay::monoid.161.471.778.1085.1392.1699.2006" = type { %class.anon.24.159.470.777.1084.1391.1698.2005, %class.point2d.51.362.669.976.1283.1590.1897 }
%class.anon.24.159.470.777.1084.1391.1698.2005 = type { i8 }
%class.anon.110.163.473.780.1087.1394.1701.2008 = type { %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, %"struct.parlay::slice.109.162.472.779.1086.1393.1700.2007"*, %"struct.parlay::monoid.161.471.778.1085.1392.1699.2006"* }
%"struct.parlay::slice.109.162.472.779.1086.1393.1700.2007" = type { %class.point2d.51.362.669.976.1283.1590.1897*, %class.point2d.51.362.669.976.1283.1590.1897* }
%class.anon.113.164.474.781.1088.1395.1702.2009 = type { %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, %"struct.parlay::monoid.161.471.778.1085.1392.1699.2006"* }
%"struct.parlay::monoid.27.166.476.783.1090.1397.1704.2011" = type { %class.anon.25.165.475.782.1089.1396.1703.2010, %class.point2d.51.362.669.976.1283.1590.1897 }
%class.anon.25.165.475.782.1089.1396.1703.2010 = type { i8 }
%class.anon.115.167.477.784.1091.1398.1705.2012 = type { %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, %"struct.parlay::slice.109.162.472.779.1086.1393.1700.2007"*, %"struct.parlay::monoid.27.166.476.783.1090.1397.1704.2011"* }
%class.anon.117.168.478.785.1092.1399.1706.2013 = type { %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, %"struct.parlay::monoid.27.166.476.783.1090.1397.1704.2011"* }
%class.anon.126.173.483.790.1097.1404.1711.2018 = type { i64*, i64*, %class.anon.123.172.482.789.1096.1403.1710.2017* }
%class.anon.123.172.482.789.1096.1403.1710.2017 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"* }
%class.anon.129.176.486.793.1100.1407.1714.2021 = type { i64*, i64*, %class.anon.127.175.485.792.1099.1406.1713.2020* }
%class.anon.127.175.485.792.1099.1406.1713.2020 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"*, %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* }
%class.anon.130.178.488.795.1102.1409.1716.2023 = type { i64*, i64*, %class.anon.128.177.487.794.1101.1408.1715.2022* }
%class.anon.128.177.487.794.1101.1408.1715.2022 = type { %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"*, %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"*, %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i32*, i8* }
%class.anon.131.180.490.797.1104.1411.1718.2025 = type { i64*, i64*, %class.anon.125.179.489.796.1103.1410.1717.2024* }
%class.anon.125.179.489.796.1103.1410.1717.2024 = type { %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"*, %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"*, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, i64* }
%struct.timeval.181.491.798.1105.1412.1719.2026 = type { i64, i64 }
%class.anon.137.182.492.799.1106.1413.1720.2027 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64**, i64* }
%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045" = type { %"struct.parlay::_sequence_base.143.200.509.816.1123.1430.1737.2044" }
%"struct.parlay::_sequence_base.143.200.509.816.1123.1430.1737.2044" = type { %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl.199.508.815.1122.1429.1736.2043" }
%"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl.199.508.815.1122.1429.1736.2043" = type { %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::_data_impl.198.507.814.1121.1428.1735.2042" }
%"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::_data_impl.198.507.814.1121.1428.1735.2042" = type { %union.anon.146.197.506.813.1120.1427.1734.2041, i8 }
%union.anon.146.197.506.813.1120.1427.1734.2041 = type { %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::long_seq.196.505.812.1119.1426.1733.2040" }
%"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::long_seq.196.505.812.1119.1426.1733.2040" = type <{ %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer.195.504.811.1118.1425.1732.2039", [6 x i8] }>
%"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer.195.504.811.1118.1425.1732.2039" = type { %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* }
%"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038" = type { i64, %union.anon.147.193.502.809.1116.1423.1730.2037 }
%union.anon.147.193.502.809.1116.1423.1730.2037 = type { [1 x i8], [7 x i8] }
%"struct.std::pair.149.202.511.818.1125.1432.1739.2046" = type { i64, %struct.vertex.52.363.670.977.1284.1591.1898* }
%"struct.parlay::slice.161.206.515.822.1129.1436.1743.2050" = type { %"class.parlay::delayed_sequence<std::pair<point2d<double>, point2d<double> >, (lambda at ./oct_tree.h:231:44)>::iterator.205.514.821.1128.1435.1742.2049", %"class.parlay::delayed_sequence<std::pair<point2d<double>, point2d<double> >, (lambda at ./oct_tree.h:231:44)>::iterator.205.514.821.1128.1435.1742.2049" }
%"class.parlay::delayed_sequence<std::pair<point2d<double>, point2d<double> >, (lambda at ./oct_tree.h:231:44)>::iterator.205.514.821.1128.1435.1742.2049" = type { %"class.parlay::delayed_sequence.158.204.513.820.1127.1434.1741.2048"*, i64 }
%"class.parlay::delayed_sequence.158.204.513.820.1127.1434.1741.2048" = type { i64, i64, %class.anon.159.203.512.819.1126.1433.1740.2047 }
%class.anon.159.203.512.819.1126.1433.1740.2047 = type { %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* }
%"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052" = type { %class.anon.156.207.516.823.1130.1437.1744.2051, %"struct.std::pair.109.420.727.1034.1341.1648.1955" }
%class.anon.156.207.516.823.1130.1437.1744.2051 = type { i8 }
%"class.parlay::sequence.162.217.526.833.1140.1447.1754.2061" = type { %"struct.parlay::_sequence_base.163.216.525.832.1139.1446.1753.2060" }
%"struct.parlay::_sequence_base.163.216.525.832.1139.1446.1753.2060" = type { %"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl.215.524.831.1138.1445.1752.2059" }
%"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl.215.524.831.1138.1445.1752.2059" = type { %"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::_data_impl.214.523.830.1137.1444.1751.2058" }
%"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::_data_impl.214.523.830.1137.1444.1751.2058" = type { %union.anon.166.213.522.829.1136.1443.1750.2057, i8 }
%union.anon.166.213.522.829.1136.1443.1750.2057 = type { %"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::long_seq.212.521.828.1135.1442.1749.2056" }
%"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::long_seq.212.521.828.1135.1442.1749.2056" = type <{ %"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::capacitated_buffer.211.520.827.1134.1441.1748.2055", [6 x i8] }>
%"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::capacitated_buffer.211.520.827.1134.1441.1748.2055" = type { %"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::capacitated_buffer::header.210.519.826.1133.1440.1747.2054"* }
%"struct.parlay::_sequence_base<std::pair<point2d<double>, point2d<double> >, parlay::allocator<std::pair<point2d<double>, point2d<double> > > >::_sequence_impl::capacitated_buffer::header.210.519.826.1133.1440.1747.2054" = type { i64, %union.anon.167.209.518.825.1132.1439.1746.2053 }
%union.anon.167.209.518.825.1132.1439.1746.2053 = type { [1 x i8], [7 x i8] }
%class.anon.170.219.528.835.1142.1449.1756.2063 = type { i64*, i64*, %class.anon.168.218.527.834.1141.1448.1755.2062* }
%class.anon.168.218.527.834.1141.1448.1755.2062 = type { %"class.parlay::sequence.162.217.526.833.1140.1447.1754.2061"*, %"struct.parlay::slice.161.206.515.822.1129.1436.1743.2050"*, %"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052"* }
%class.anon.172.221.530.837.1144.1451.1758.2065 = type { i64*, i64*, %class.anon.171.220.529.836.1143.1450.1757.2064* }
%class.anon.171.220.529.836.1143.1450.1757.2064 = type { %"class.parlay::sequence.162.217.526.833.1140.1447.1754.2061"*, %"class.parlay::sequence.162.217.526.833.1140.1447.1754.2061"*, %"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052"* }
%"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069" = type { %"class.parlay::delayed_sequence<std::pair<unsigned long, vertex<point2d<double> > *>, (lambda at ./oct_tree.h:252:57)>::iterator.224.533.840.1147.1454.1761.2068", %"class.parlay::delayed_sequence<std::pair<unsigned long, vertex<point2d<double> > *>, (lambda at ./oct_tree.h:252:57)>::iterator.224.533.840.1147.1454.1761.2068" }
%"class.parlay::delayed_sequence<std::pair<unsigned long, vertex<point2d<double> > *>, (lambda at ./oct_tree.h:252:57)>::iterator.224.533.840.1147.1454.1761.2068" = type { %"class.parlay::delayed_sequence.152.223.532.839.1146.1453.1760.2067"*, i64 }
%"class.parlay::delayed_sequence.152.223.532.839.1146.1453.1760.2067" = type { i64, i64, %class.anon.153.222.531.838.1145.1452.1759.2066 }
%class.anon.153.222.531.838.1145.1452.1759.2066 = type { %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, %"struct.std::pair.109.420.727.1034.1341.1648.1955"*, double* }
%class.anon.154.226.535.842.1149.1456.1763.2070 = type { i8 }
%"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079" = type { %"struct.parlay::_sequence_base.178.234.543.850.1157.1464.1771.2078" }
%"struct.parlay::_sequence_base.178.234.543.850.1157.1464.1771.2078" = type { %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl.233.542.849.1156.1463.1770.2077" }
%"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl.233.542.849.1156.1463.1770.2077" = type { %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::_data_impl.232.541.848.1155.1462.1769.2076" }
%"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::_data_impl.232.541.848.1155.1462.1769.2076" = type { %union.anon.181.231.540.847.1154.1461.1768.2075, i8 }
%union.anon.181.231.540.847.1154.1461.1768.2075 = type { %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::long_seq.230.539.846.1153.1460.1767.2074" }
%"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::long_seq.230.539.846.1153.1460.1767.2074" = type <{ %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer.229.538.845.1152.1459.1766.2073", [6 x i8] }>
%"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer.229.538.845.1152.1459.1766.2073" = type { %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"* }
%"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072" = type <{ i64, %union.anon.182.227.536.843.1150.1457.1764.2071, [4 x i8] }>
%union.anon.182.227.536.843.1150.1457.1764.2071 = type { [1 x i8], [3 x i8] }
%class.anon.184.237.546.853.1160.1467.1774.2081 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, %class.anon.154.226.535.842.1149.1456.1763.2070*, %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"struct.parlay::slice.148.236.545.852.1159.1466.1773.2080"*, i8* }
%"struct.parlay::slice.148.236.545.852.1159.1466.1773.2080" = type { %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* }
%class.anon.175.238.547.854.1161.1468.1775.2082 = type { %"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"*, i64* }
%class.anon.191.239.548.855.1162.1469.1776.2083 = type { %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"**, %class.anon.175.238.547.854.1161.1468.1775.2082* }
%"class.std::tuple.192.246.555.862.1169.1476.1783.2090" = type { %"struct.std::_Tuple_impl.193.245.554.861.1168.1475.1782.2089" }
%"struct.std::_Tuple_impl.193.245.554.861.1168.1475.1782.2089" = type { %"struct.std::_Tuple_impl.194.243.552.859.1166.1473.1780.2087", %"struct.std::_Head_base.198.244.553.860.1167.1474.1781.2088" }
%"struct.std::_Tuple_impl.194.243.552.859.1166.1473.1780.2087" = type { %"struct.std::_Tuple_impl.195.241.550.857.1164.1471.1778.2085", %"struct.std::_Head_base.197.242.551.858.1165.1472.1779.2086" }
%"struct.std::_Tuple_impl.195.241.550.857.1164.1471.1778.2085" = type { %"struct.std::_Head_base.196.240.549.856.1163.1470.1777.2084" }
%"struct.std::_Head_base.196.240.549.856.1163.1470.1777.2084" = type { i8 }
%"struct.std::_Head_base.197.242.551.858.1165.1472.1779.2086" = type { %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* }
%"struct.std::_Head_base.198.244.553.860.1167.1474.1781.2088" = type { %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* }
%class.anon.176.247.556.863.1170.1477.1784.2091 = type { %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* }
%class.anon.203.248.557.864.1171.1478.1785.2092 = type { %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"**, %class.anon.176.247.556.863.1170.1477.1784.2091* }
%class.anon.204.252.561.868.1175.1482.1789.2096 = type { i64*, i64*, %class.anon.183.251.560.867.1174.1481.1788.2095* }
%class.anon.183.251.560.867.1174.1481.1788.2095 = type { %"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"*, %"class.parlay::internal::uninitialized_sequence.250.559.866.1173.1480.1787.2094"*, %class.anon.154.226.535.842.1149.1456.1763.2070*, i8*, %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64* }
%"class.parlay::internal::uninitialized_sequence.250.559.866.1173.1480.1787.2094" = type { %"struct.parlay::internal::uninitialized_sequence<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::uninitialized_sequence_impl.249.558.865.1172.1479.1786.2093" }
%"struct.parlay::internal::uninitialized_sequence<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::uninitialized_sequence_impl.249.558.865.1172.1479.1786.2093" = type { i64, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* }
%class.anon.208.253.562.869.1176.1483.1790.2097 = type { i64*, i64*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"**, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"** }
%class.anon.207.254.563.870.1177.1484.1791.2098 = type { %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64*, i64*, i64* }
%class.anon.210.255.564.871.1178.1485.1792.2099 = type { %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i32**, %class.anon.207.254.563.870.1177.1484.1791.2098* }
%"struct.parlay::slice.205.256.565.872.1179.1486.1793.2100" = type { i32*, i32* }
%"struct.parlay::addm.206.257.566.873.1180.1487.1794.2101" = type { i32 }
%class.anon.213.259.568.875.1182.1489.1796.2103 = type { i64*, i64*, %class.anon.211.258.567.874.1181.1488.1795.2102* }
%class.anon.211.258.567.874.1181.1488.1795.2102 = type { %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"struct.parlay::slice.205.256.565.872.1179.1486.1793.2100"*, %"struct.parlay::addm.206.257.566.873.1180.1487.1794.2101"* }
%class.anon.214.261.570.877.1184.1491.1798.2105 = type { i64*, i64*, %class.anon.212.260.569.876.1183.1490.1797.2104* }
%class.anon.212.260.569.876.1183.1490.1797.2104 = type { %"struct.parlay::slice.205.256.565.872.1179.1486.1793.2100"*, %"struct.parlay::slice.205.256.565.872.1179.1486.1793.2100"*, %"struct.parlay::addm.206.257.566.873.1180.1487.1794.2101"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i32*, i8* }
%"struct.parlay::internal::transpose.262.571.878.1185.1492.1799.2106" = type { i32*, i32* }
%"struct.parlay::internal::blockTrans.263.572.879.1186.1493.1800.2107" = type { %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, i32*, i32* }
%class.anon.209.265.573.880.1187.1494.1801.2108 = type { i64*, i64*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64* }
%class.anon.225.266.574.881.1188.1495.1802.2109 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64**, %class.anon.209.265.573.880.1187.1494.1801.2108* }
%class.anon.229.267.575.882.1189.1496.1803.2110 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, %class.anon.154.226.535.842.1149.1456.1763.2070*, %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"struct.parlay::slice.148.236.545.852.1159.1466.1773.2080"*, i8* }
%class.anon.226.268.576.883.1190.1497.1804.2111 = type { %"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"*, i64* }
%class.anon.230.269.577.884.1191.1498.1805.2112 = type { %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"**, %class.anon.226.268.576.883.1190.1497.1804.2111* }
%class.anon.227.270.578.885.1192.1499.1806.2113 = type { %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* }
%class.anon.231.271.579.886.1193.1500.1807.2114 = type { %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"**, %class.anon.227.270.578.885.1192.1499.1806.2113* }
%class.anon.232.273.581.888.1195.1502.1809.2116 = type { i64*, i64*, %class.anon.228.272.580.887.1194.1501.1808.2115* }
%class.anon.228.272.580.887.1194.1501.1808.2115 = type { %"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"*, %"class.parlay::internal::uninitialized_sequence.250.559.866.1173.1480.1787.2094"*, %class.anon.154.226.535.842.1149.1456.1763.2070*, i8*, %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64* }
%class.anon.234.274.582.889.1196.1503.1810.2117 = type { i64*, i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"**, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"** }
%class.anon.233.275.583.890.1197.1504.1811.2118 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, i64*, i64* }
%class.anon.238.276.584.891.1198.1505.1812.2119 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64**, %class.anon.233.275.583.890.1197.1504.1811.2118* }
%"struct.parlay::internal::transpose.235.277.585.892.1199.1506.1813.2120" = type { i64*, i64* }
%"struct.parlay::internal::blockTrans.236.278.586.893.1200.1507.1814.2121" = type { %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, i64*, i64* }
%class.anon.237.280.587.894.1201.1508.1815.2122 = type { i64*, i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64* }
%class.anon.248.281.588.895.1202.1509.1816.2123 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64**, %class.anon.237.280.587.894.1201.1508.1815.2122* }
%"struct.k_nearest_neighbors<vertex<point2d<double> >, 1>::kNN.283.590.897.1204.1511.1818.2125" = type { %struct.vertex.52.363.670.977.1284.1591.1898*, [1 x %struct.vertex.52.363.670.977.1284.1591.1898*], [1 x double], i32, i32, i64, i64 }
%class.anon.270.288.595.902.1209.1516.1823.2130 = type { i8 }
%class.anon.272.289.596.903.1210.1517.1824.2131 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64**, %class.anon.270.288.595.902.1209.1516.1823.2130* }
%class.anon.285.291.598.905.1212.1519.1826.2133 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"*, %"struct.parlay::random.290.597.904.1211.1518.1825.2132"* }
%"struct.parlay::random.290.597.904.1211.1518.1825.2132" = type { i64 }
%"struct.std::pair.276.292.599.906.1213.1520.1827.2134" = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927", i8 }
%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138" = type { %"class.parlay::delayed_sequence<unsigned long, (lambda at ./parlay/random.h:73:19)>::iterator.295.602.909.1216.1523.1830.2137", %"class.parlay::delayed_sequence<unsigned long, (lambda at ./parlay/random.h:73:19)>::iterator.295.602.909.1216.1523.1830.2137" }
%"class.parlay::delayed_sequence<unsigned long, (lambda at ./parlay/random.h:73:19)>::iterator.295.602.909.1216.1523.1830.2137" = type { %"class.parlay::delayed_sequence.275.294.601.908.1215.1522.1829.2136"*, i64 }
%"class.parlay::delayed_sequence.275.294.601.908.1215.1522.1829.2136" = type { i64, i64, %class.anon.274.293.600.907.1214.1521.1828.2135 }
%class.anon.274.293.600.907.1214.1521.1828.2135 = type { %"struct.parlay::random.290.597.904.1211.1518.1825.2132"*, i64* }
%class.anon.286.297.604.911.1218.1525.1832.2139 = type { i64*, i64*, %"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993"*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64* }
%class.anon.287.298.605.912.1219.1526.1833.2140 = type { i64*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* }
%class.anon.288.299.606.913.1220.1527.1834.2141 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64* }
%class.anon.289.300.607.914.1221.1528.1835.2142 = type { i64*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64* }
%class.anon.290.301.608.915.1222.1529.1836.2143 = type { i64*, i64*, %"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993"*, %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64* }
%class.anon.291.302.609.916.1223.1530.1837.2144 = type { i64*, i64*, %"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993"*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64* }
%class.anon.292.303.610.917.1224.1531.1838.2145 = type { i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* }
%class.anon.293.304.611.918.1225.1532.1839.2146 = type { %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64* }
%class.anon.294.305.612.919.1226.1533.1840.2147 = type { i64*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64* }
%class.anon.295.306.613.920.1227.1534.1841.2148 = type { i64*, i64*, %"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993"*, %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64* }
%class.anon.296.307.614.921.1228.1535.1842.2149 = type { %struct.vertex.52.363.670.977.1284.1591.1898***, %struct.vertex.52.363.670.977.1284.1591.1898***, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl.106.417.724.1031.1338.1645.1952"* }
%class.anon.297.308.615.922.1229.1536.1843.2150 = type { %class.point2d.51.362.669.976.1283.1590.1897**, %class.point2d.51.362.669.976.1283.1590.1897**, %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl.88.399.706.1013.1320.1627.1934"* }
%class.anon.298.310.617.924.1231.1538.1845.2152 = type { %"struct.std::array.309.616.923.1230.1537.1844.2151"**, %"struct.std::array.309.616.923.1230.1537.1844.2151"**, %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl.143.454.761.1068.1375.1682.1989"* }
%"struct.std::array.309.616.923.1230.1537.1844.2151" = type { [3 x i32] }

$_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev = comdat any

$_ZN8oct_treeI6vertexI7point2dIdEEE5buildIN6parlay8sequenceIPS3_NS6_9allocatorIS8_EEEEEESt10unique_ptrINS4_4nodeENS4_11delete_treeEERT_ = comdat any

$_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi = comdat any

$_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_jEES4_T0_T1_RNS1_IT2_NS2_ISJ_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSO_mb = comdat any

@_ZStL8__ioinit = external dso_local global %"class.std::ios_base::Init.0.311.618.925.1232.1539.1846", align 1
@__dso_handle = external hidden global i8
@_ZL3_tm = external dso_local global %struct.timer.5.316.623.930.1237.1544.1851, align 8
@.str = external dso_local unnamed_addr constant [10 x i8], align 1
@_ZSt4cout = external dso_local global %"class.std::basic_ostream.20.331.638.945.1252.1559.1866", align 8
@.str.2 = external dso_local unnamed_addr constant [32 x i8], align 1
@.str.3 = external dso_local unnamed_addr constant [5 x i8], align 1
@.str.5 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.6 = external dso_local unnamed_addr constant [11 x i8], align 1
@.str.7 = external dso_local unnamed_addr constant [16 x i8], align 1
@_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE = external dso_local global %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", align 64
@_ZGVN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE = external dso_local local_unnamed_addr global i64, align 8
@.str.9 = external dso_local unnamed_addr constant [42 x i8], align 1
@_ZZN6parlay8internal21get_default_allocatorEvE17default_allocator = external dso_local global %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896", align 8
@_ZGVZN6parlay8internal21get_default_allocatorEvE17default_allocator = external dso_local global i64, align 8
@.str.10 = external dso_local unnamed_addr constant [26 x i8], align 1
@.str.11 = external dso_local unnamed_addr constant [53 x i8], align 1
@_ZTISt16invalid_argument = external dso_local constant i8*
@.str.12 = external dso_local unnamed_addr constant [48 x i8], align 1
@_ZTISt9bad_alloc = external dso_local constant i8*
@_ZTVSt9bad_alloc = external dso_local unnamed_addr constant { [5 x i8*] }, align 8
@.str.14 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.15 = external dso_local unnamed_addr constant [46 x i8], align 1
@.str.16 = external dso_local unnamed_addr constant [16 x i8], align 1
@.str.17 = external dso_local unnamed_addr constant [13 x i8], align 1
@.str.18 = external dso_local unnamed_addr constant [22 x i8], align 1
@.str.19 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.20 = external dso_local unnamed_addr constant [2 x i8], align 1
@.str.21 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.22 = external dso_local unnamed_addr constant [10 x i8], align 1
@.str.23 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.24 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.25 = external dso_local unnamed_addr constant [3 x i8], align 1
@.str.26 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.27 = external dso_local unnamed_addr constant [30 x i8], align 1
@.str.29 = external dso_local unnamed_addr constant [4 x i8], align 1
@.str.30 = external dso_local unnamed_addr constant [6 x i8], align 1
@.str.31 = external dso_local unnamed_addr constant [8 x i8], align 1
@.str.32 = external dso_local unnamed_addr constant [18 x i8], align 1

declare dso_local void @_ZNSt8ios_base4InitC1Ev(%"class.std::ios_base::Init.0.311.618.925.1232.1539.1846"*) unnamed_addr #0

; Function Attrs: nounwind
declare dso_local void @_ZNSt8ios_base4InitD1Ev(%"class.std::ios_base::Init.0.311.618.925.1232.1539.1846"*) unnamed_addr #1

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_atexit(void (i8*)*, i8*, i8*) local_unnamed_addr #2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.start.p0i8(i64 immarg, i8* nocapture) #3

declare dso_local i32 @__gxx_personality_v0(...)

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN5timerC2ENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEEb(%struct.timer.5.316.623.930.1237.1544.1851*, %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"*, i1 zeroext) unnamed_addr #4 align 2

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.lifetime.end.p0i8(i64 immarg, i8* nocapture) #3

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local void @_ZN5timerD2Ev(%struct.timer.5.316.623.930.1237.1544.1851*) unnamed_addr #5 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local { %struct.triangle.53.364.671.978.1285.1592.1899*, i64 } @_Z4findP6vertexI7point2dIdEE7simplexIS1_E(%struct.vertex.52.363.670.977.1284.1591.1898* nocapture readonly, %struct.triangle.53.364.671.978.1285.1592.1899*, i64) local_unnamed_addr #4

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* noalias nocapture writeonly, i8* noalias nocapture readonly, i64, i1 immarg) #3

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_Z10findCavity7simplexI7point2dIdEEP6vertexIS1_EP2QsIS1_E(%struct.triangle.53.364.671.978.1285.1592.1899*, i64, %struct.vertex.52.363.670.977.1284.1591.1898* readonly, %struct.Qs.63.374.681.988.1295.1602.1909*) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_Z18reserve_for_insertP6vertexI7point2dIdEE7simplexIS1_EP2QsIS1_E(%struct.vertex.52.363.670.977.1284.1591.1898* readonly, %struct.triangle.53.364.671.978.1285.1592.1899*, i64, %struct.Qs.63.374.681.988.1295.1602.1909*) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local zeroext i1 @_Z6insertP6vertexI7point2dIdEE7simplexIS1_EP2QsIS1_E(%struct.vertex.52.363.670.977.1284.1591.1898*, %struct.triangle.53.364.671.978.1285.1592.1899*, i64, %struct.Qs.63.374.681.988.1295.1602.1909* nocapture) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN7simplexI7point2dIdEE5splitEP6vertexIS1_EP8triangleIS1_ES8_(%struct.simplex.58.369.676.983.1290.1597.1904*, %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.triangle.53.364.671.978.1285.1592.1899*, %struct.triangle.53.364.671.978.1285.1592.1899*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN7simplexI7point2dIdEE4flipEv(%struct.simplex.58.369.676.983.1290.1597.1904*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_Z14check_delaunayRN6parlay8sequenceI8triangleI7point2dIdEENS_9allocatorIS4_EEEEm(%"class.parlay::sequence.72.383.690.997.1304.1611.1918"* dereferenceable(15), i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZ14check_delaunayRNS_8sequenceI8triangleI7point2dIdEENS_9allocatorIS5_EEEEmE3$_0EEvmmT_mb"(i64, %"class.parlay::sequence.72.383.690.997.1304.1611.1918"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*) unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* dereferenceable(272), i8*) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZSt4endlIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* dereferenceable(272)) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_Z17generate_boundaryRKN6parlay8sequenceI7point2dIdENS_9allocatorIS2_EEEEmRNS0_I6vertexIS2_ENS3_IS9_EEEERNS0_I8triangleIS2_ENS3_ISE_EEEE(%"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"* dereferenceable(15), i64, %"class.parlay::sequence.19.99.410.717.1024.1331.1638.1945"* dereferenceable(15), %"class.parlay::sequence.72.383.690.997.1304.1611.1918"* dereferenceable(15)) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare dso_local double @cos(double) local_unnamed_addr #7

; Function Attrs: nofree nounwind
declare dso_local double @sin(double) local_unnamed_addr #7

; Function Attrs: sanitize_cilk uwtable
define dso_local void @_Z24incrementally_add_pointsN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEES5_(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %v, %struct.vertex.52.363.670.977.1284.1591.1898* %start) local_unnamed_addr #4 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg19.i.i.i516 = tail call token @llvm.syncregion.start()
  %n.addr.i25.i = alloca i64, align 8
  %block_size.addr.i26.i = alloca i64, align 8
  %In.i.i = alloca %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019", align 8
  %m.i.i = alloca %"struct.parlay::addm.154.465.772.1079.1386.1693.2000", align 8
  %n.addr.i.i = alloca i64, align 8
  %block_size.addr.i.i = alloca i64, align 8
  %Out.i = alloca %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", align 8
  %l.i = alloca i64, align 8
  %Sums.i = alloca %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927", align 8
  %ref.tmp6.i = alloca %class.anon.264.286.593.900.1207.1514.1821.2128, align 8
  %m.i = alloca i64, align 8
  %ref.tmp15.i = alloca %class.anon.265.287.594.901.1208.1515.1822.2129, align 8
  %tmp.i.i.i = alloca [15 x i8], align 1
  %ref.tmp.i186 = alloca %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", align 8
  %ref.tmp1.i = alloca %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016", align 8
  %syncreg.i = tail call token @llvm.syncregion.start()
  %ref.tmp.i119 = alloca %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962", align 8
  %first.addr.i = alloca %struct.vertex.52.363.670.977.1284.1591.1898**, align 8
  %buffer.i = alloca %struct.vertex.52.363.670.977.1284.1591.1898**, align 8
  %agg.tmp.i = alloca %class.anon.262.282.589.896.1203.1510.1817.2124, align 8
  %ref.tmp.i = alloca %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962", align 8
  %buffer.i.i.i = alloca %struct.Qs.63.374.681.988.1295.1602.1909*, align 8
  %done = alloca %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", align 8
  %buffer = alloca %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", align 8
  %remain = alloca %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", align 8
  %t = alloca %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972", align 8
  %flags = alloca %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", align 8
  %VQ = alloca %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", align 8
  %ref.tmp = alloca %class.anon.48.169.479.786.1093.1400.1707.2014, align 1
  %init = alloca %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", align 8
  %knn = alloca %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963, align 8
  %num_done = alloca i64, align 8
  %num_remain = alloca i64, align 8
  %vtxs = alloca %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", align 8
  %ref.tmp21 = alloca %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963, align 8
  %agg.tmp = alloca %class.anon.52.136.447.754.1061.1368.1675.1982, align 8
  %agg.tmp40 = alloca %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", align 8
  %not_flags = alloca %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127", align 8
  %ref.tmp62 = alloca %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", align 8
  %0 = ptrtoint %struct.vertex.52.363.670.977.1284.1591.1898* %start to i64
  %flag.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %v, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i = load i8, i8* %flag.i.i.i, align 1
  %cmp.i.i.i = icmp sgt i8 %bf.load.i.i.i, -1
  br i1 %cmp.i.i.i, label %if.then.i.i, label %if.else.i.i

if.then.i.i:                                      ; preds = %entry
  %conv.i.i = zext i8 %bf.load.i.i.i to i64
  br label %_ZNK6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE4sizeEv.exit

if.else.i.i:                                      ; preds = %entry
  %n.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %v, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %1 = bitcast [6 x i8]* %n.i.i.i to i48*
  %bf.load.i1.i.i = load i48, i48* %1, align 1
  %bf.cast.i.i.i = zext i48 %bf.load.i1.i.i to i64
  br label %_ZNK6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE4sizeEv.exit

_ZNK6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE4sizeEv.exit: ; preds = %if.else.i.i, %if.then.i.i
  %retval.0.i.i = phi i64 [ %conv.i.i, %if.then.i.i ], [ %bf.cast.i.i.i, %if.else.i.i ]
  %div = udiv i64 %retval.0.i.i, 1000
  %add = add nuw nsw i64 %div, 1
  %2 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %2) #16
  %small_n.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i, align 2
  invoke void @_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEm(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* nonnull %done, i64 %retval.0.i.i)
          to label %_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEC2Em.exit unwind label %lpad.i

lpad.i:                                           ; preds = %_ZNK6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE4sizeEv.exit
  %3 = landingpad { i8*, i32 }
          cleanup
  %bf.load.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i, label %if.then.i.i.i.i

if.then.i.i.i.i:                                  ; preds = %lpad.i
  %buffer.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %4 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i, align 8, !tbaa !2
  %capacity.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %4, i64 0, i32 0
  %5 = load i64, i64* %capacity.i.i.i.i.i.i, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i unwind label %lpad.i.i.i

call.i.i.i.i.i.noexc.i.i.i:                       ; preds = %if.then.i.i.i.i
  %6 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %4 to i8*
  %mul.i.i.i.i.i.i = shl i64 %5, 3
  %add.i.i.i.i.i.i = add i64 %mul.i.i.i.i.i.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i, i8* %6, i64 %add.i.i.i.i.i.i)
          to label %.noexc.i.i.i unwind label %lpad.i.i.i

.noexc.i.i.i:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.i
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i

lpad.i.i.i:                                       ; preds = %call.i.i.i.i.i.noexc.i.i.i, %if.then.i.i.i.i
  %7 = landingpad { i8*, i32 }
          catch i8* null
  %8 = extractvalue { i8*, i32 } %7, 0
  call void @__clang_call_terminate(i8* %8) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i: ; preds = %.noexc.i.i.i, %lpad.i
  resume { i8*, i32 } %3

_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEC2Em.exit: ; preds = %_ZNK6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE4sizeEv.exit
  %9 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %9) #16
  %small_n.i.i.i.i28 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i28, align 2
  invoke void @_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEm(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* nonnull %buffer, i64 %add)
          to label %_ZNK6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl8capacityEv.exit.i.i unwind label %lpad.i31

lpad.i31:                                         ; preds = %_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEC2Em.exit
  %10 = landingpad { i8*, i32 }
          cleanup
  %bf.load.i.i.i.i.i29 = load i8, i8* %small_n.i.i.i.i28, align 2
  %cmp.i.i.i.i.i30 = icmp sgt i8 %bf.load.i.i.i.i.i29, -1
  br i1 %cmp.i.i.i.i.i30, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i41, label %if.then.i.i.i.i35

if.then.i.i.i.i35:                                ; preds = %lpad.i31
  %buffer.i.i.i.i.i32 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %11 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i32, align 8, !tbaa !2
  %capacity.i.i.i.i.i.i33 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %11, i64 0, i32 0
  %12 = load i64, i64* %capacity.i.i.i.i.i.i33, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i.i34 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i38 unwind label %lpad.i.i.i40

call.i.i.i.i.i.noexc.i.i.i38:                     ; preds = %if.then.i.i.i.i35
  %13 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %11 to i8*
  %mul.i.i.i.i.i.i36 = shl i64 %12, 3
  %add.i.i.i.i.i.i37 = add i64 %mul.i.i.i.i.i.i36, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i34, i8* %13, i64 %add.i.i.i.i.i.i37)
          to label %.noexc.i.i.i39 unwind label %lpad.i.i.i40

.noexc.i.i.i39:                                   ; preds = %call.i.i.i.i.i.noexc.i.i.i38
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i32, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i41

lpad.i.i.i40:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.i38, %if.then.i.i.i.i35
  %14 = landingpad { i8*, i32 }
          catch i8* null
  %15 = extractvalue { i8*, i32 } %14, 0
  call void @__clang_call_terminate(i8* %15) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i41: ; preds = %.noexc.i.i.i39, %lpad.i31
  store i8 0, i8* %small_n.i.i.i.i28, align 2
  %16 = extractvalue { i8*, i32 } %10, 0
  %17 = extractvalue { i8*, i32 } %10, 1
  br label %ehcleanup97

_ZNK6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl8capacityEv.exit.i.i: ; preds = %_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEC2Em.exit
  %18 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %remain to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %18) #16
  %small_n.i.i.i.i43 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %remain, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i43, align 2
  %19 = bitcast %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %19) #16
  %small_n.i.i.i.i44 = getelementptr inbounds %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972", %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 -128, i8* %small_n.i.i.i.i44, align 2
  %call.i.i.i.i.i.i513 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc512 unwind label %lpad.i47

call.i.i.i.i.i.i.noexc512:                        ; preds = %_ZNK6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl8capacityEv.exit.i.i
  %mul.i.i.i.i = shl nuw nsw i64 %add, 4
  %add.i.i.i.i493 = or i64 %mul.i.i.i.i, 8
  %call2.i.i.i.i.i.i515 = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i.i513, i64 %add.i.i.i.i493)
          to label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i unwind label %lpad.i47

_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i: ; preds = %call.i.i.i.i.i.i.noexc512
  %capacity.i.i.i3.i.i494 = bitcast i8* %call2.i.i.i.i.i.i515 to i64*
  store i64 %add, i64* %capacity.i.i.i3.i.i494, align 8, !tbaa !10
  %20 = bitcast %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t to i8**
  store i8* %call2.i.i.i.i.i.i515, i8** %20, align 8, !tbaa.struct !12
  %ref.tmp.sroa.4.0..sroa_idx5.i.i495 = getelementptr inbounds %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972", %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i496 = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i495 to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i496, align 8, !tbaa.struct !12
  %bf.load.i.i.i498.pr = load i8, i8* %small_n.i.i.i.i44, align 2
  %cmp.i.i.i499 = icmp sgt i8 %bf.load.i.i.i498.pr, -1
  %21 = bitcast %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t to %struct.simplex.58.369.676.983.1290.1597.1904*
  %buffer.i.i.i.i500 = getelementptr inbounds %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972", %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %data.i.i.i.i.i501 = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i515, i64 8
  %22 = bitcast i8* %data.i.i.i.i.i501 to %struct.simplex.58.369.676.983.1290.1597.1904*
  %retval.0.i.i503 = select i1 %cmp.i.i.i499, %struct.simplex.58.369.676.983.1290.1597.1904* %21, %struct.simplex.58.369.676.983.1290.1597.1904* %22
  %xtraiter21 = and i64 %div, 2047
  %23 = add nuw nsw i64 %xtraiter21, 1
  %24 = icmp ult i64 %retval.0.i.i, 2048000
  br i1 %24, label %pfor.cond.i.i.epil.preheader, label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.new

_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.new: ; preds = %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i
  %stripiter24 = udiv i64 %retval.0.i.i, 2048000
  br label %pfor.cond.i.i.strpm.outer

pfor.cond.i.i.strpm.outer:                        ; preds = %pfor.inc.i.i.strpm.outer, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.new
  %niter25 = phi i64 [ 0, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i.new ], [ %niter25.nadd, %pfor.inc.i.i.strpm.outer ]
  detach within %syncreg19.i.i.i516, label %pfor.body.i.i.strpm.outer, label %pfor.inc.i.i.strpm.outer

pfor.body.i.i.strpm.outer:                        ; preds = %pfor.cond.i.i.strpm.outer
  %25 = shl i64 %niter25, 11
  br label %pfor.cond.i.i

pfor.cond.i.i:                                    ; preds = %pfor.cond.i.i, %pfor.body.i.i.strpm.outer
  %__begin.0.i.i = phi i64 [ %25, %pfor.body.i.i.strpm.outer ], [ %inc.i.i505.1, %pfor.cond.i.i ]
  %inneriter26 = phi i64 [ 2048, %pfor.body.i.i.strpm.outer ], [ %inneriter26.nsub.1, %pfor.cond.i.i ]
  %t.i.i.i.i.i.i.i = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %__begin.0.i.i, i32 0
  store %struct.triangle.53.364.671.978.1285.1592.1899* null, %struct.triangle.53.364.671.978.1285.1592.1899** %t.i.i.i.i.i.i.i, align 8, !tbaa !15
  %o.i.i.i.i.i.i.i = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %__begin.0.i.i, i32 1
  store i32 0, i32* %o.i.i.i.i.i.i.i, align 8, !tbaa !19
  %boundary.i.i.i.i.i.i.i = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %__begin.0.i.i, i32 2
  store i8 0, i8* %boundary.i.i.i.i.i.i.i, align 4, !tbaa !20
  %inc.i.i505 = or i64 %__begin.0.i.i, 1
  %t.i.i.i.i.i.i.i.1 = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %inc.i.i505, i32 0
  store %struct.triangle.53.364.671.978.1285.1592.1899* null, %struct.triangle.53.364.671.978.1285.1592.1899** %t.i.i.i.i.i.i.i.1, align 8, !tbaa !15
  %o.i.i.i.i.i.i.i.1 = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %inc.i.i505, i32 1
  store i32 0, i32* %o.i.i.i.i.i.i.i.1, align 8, !tbaa !19
  %boundary.i.i.i.i.i.i.i.1 = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %inc.i.i505, i32 2
  store i8 0, i8* %boundary.i.i.i.i.i.i.i.1, align 4, !tbaa !20
  %inc.i.i505.1 = add nuw nsw i64 %__begin.0.i.i, 2
  %inneriter26.nsub.1 = add nsw i64 %inneriter26, -2
  %inneriter26.ncmp.1 = icmp eq i64 %inneriter26.nsub.1, 0
  br i1 %inneriter26.ncmp.1, label %pfor.inc.i.i.reattach, label %pfor.cond.i.i, !llvm.loop !21

pfor.inc.i.i.reattach:                            ; preds = %pfor.cond.i.i
  reattach within %syncreg19.i.i.i516, label %pfor.inc.i.i.strpm.outer

pfor.inc.i.i.strpm.outer:                         ; preds = %pfor.inc.i.i.reattach, %pfor.cond.i.i.strpm.outer
  %niter25.nadd = add nuw nsw i64 %niter25, 1
  %niter25.ncmp = icmp eq i64 %niter25.nadd, %stripiter24
  br i1 %niter25.ncmp, label %pfor.cond.i.i.epil.preheader, label %pfor.cond.i.i.strpm.outer, !llvm.loop !23

pfor.cond.i.i.epil.preheader:                     ; preds = %pfor.inc.i.i.strpm.outer, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl19initialize_capacityEm.exit.i
  %26 = udiv i64 %retval.0.i.i, 2048000
  %27 = shl nuw nsw i64 %26, 11
  %xtraiter1 = and i64 %23, 1
  %lcmp.mod2 = icmp eq i64 %xtraiter1, 0
  br i1 %lcmp.mod2, label %pfor.cond.i.i.epil.prol.loopexit, label %pfor.cond.i.i.epil.prol

pfor.cond.i.i.epil.prol:                          ; preds = %pfor.cond.i.i.epil.preheader
  %t.i.i.i.i.i.i.i.epil.prol = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %27, i32 0
  store %struct.triangle.53.364.671.978.1285.1592.1899* null, %struct.triangle.53.364.671.978.1285.1592.1899** %t.i.i.i.i.i.i.i.epil.prol, align 8, !tbaa !15
  %o.i.i.i.i.i.i.i.epil.prol = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %27, i32 1
  store i32 0, i32* %o.i.i.i.i.i.i.i.epil.prol, align 8, !tbaa !19
  %boundary.i.i.i.i.i.i.i.epil.prol = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %27, i32 2
  store i8 0, i8* %boundary.i.i.i.i.i.i.i.epil.prol, align 4, !tbaa !20
  %inc.i.i505.epil.prol = or i64 %27, 1
  br label %pfor.cond.i.i.epil.prol.loopexit

pfor.cond.i.i.epil.prol.loopexit:                 ; preds = %pfor.cond.i.i.epil.prol, %pfor.cond.i.i.epil.preheader
  %__begin.0.i.i.epil.unr = phi i64 [ %27, %pfor.cond.i.i.epil.preheader ], [ %inc.i.i505.epil.prol, %pfor.cond.i.i.epil.prol ]
  %epil.iter22.unr = phi i64 [ %23, %pfor.cond.i.i.epil.preheader ], [ %xtraiter21, %pfor.cond.i.i.epil.prol ]
  %28 = icmp eq i64 %xtraiter21, 0
  br i1 %28, label %pfor.cond.cleanup.i.i, label %pfor.cond.i.i.epil

pfor.cond.i.i.epil:                               ; preds = %pfor.cond.i.i.epil, %pfor.cond.i.i.epil.prol.loopexit
  %__begin.0.i.i.epil = phi i64 [ %inc.i.i505.epil.1, %pfor.cond.i.i.epil ], [ %__begin.0.i.i.epil.unr, %pfor.cond.i.i.epil.prol.loopexit ]
  %epil.iter22 = phi i64 [ %epil.iter22.sub.1, %pfor.cond.i.i.epil ], [ %epil.iter22.unr, %pfor.cond.i.i.epil.prol.loopexit ]
  %t.i.i.i.i.i.i.i.epil = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %__begin.0.i.i.epil, i32 0
  store %struct.triangle.53.364.671.978.1285.1592.1899* null, %struct.triangle.53.364.671.978.1285.1592.1899** %t.i.i.i.i.i.i.i.epil, align 8, !tbaa !15
  %o.i.i.i.i.i.i.i.epil = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %__begin.0.i.i.epil, i32 1
  store i32 0, i32* %o.i.i.i.i.i.i.i.epil, align 8, !tbaa !19
  %boundary.i.i.i.i.i.i.i.epil = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %__begin.0.i.i.epil, i32 2
  store i8 0, i8* %boundary.i.i.i.i.i.i.i.epil, align 4, !tbaa !20
  %inc.i.i505.epil = add nuw nsw i64 %__begin.0.i.i.epil, 1
  %t.i.i.i.i.i.i.i.epil.1 = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %inc.i.i505.epil, i32 0
  store %struct.triangle.53.364.671.978.1285.1592.1899* null, %struct.triangle.53.364.671.978.1285.1592.1899** %t.i.i.i.i.i.i.i.epil.1, align 8, !tbaa !15
  %o.i.i.i.i.i.i.i.epil.1 = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %inc.i.i505.epil, i32 1
  store i32 0, i32* %o.i.i.i.i.i.i.i.epil.1, align 8, !tbaa !19
  %boundary.i.i.i.i.i.i.i.epil.1 = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i503, i64 %inc.i.i505.epil, i32 2
  store i8 0, i8* %boundary.i.i.i.i.i.i.i.epil.1, align 4, !tbaa !20
  %inc.i.i505.epil.1 = add nuw nsw i64 %__begin.0.i.i.epil, 2
  %epil.iter22.sub.1 = add nsw i64 %epil.iter22, -2
  %epil.iter22.cmp.1 = icmp eq i64 %epil.iter22.sub.1, 0
  br i1 %epil.iter22.cmp.1, label %pfor.cond.cleanup.i.i, label %pfor.cond.i.i.epil, !llvm.loop !26

pfor.cond.cleanup.i.i:                            ; preds = %pfor.cond.i.i.epil, %pfor.cond.i.i.epil.prol.loopexit
  sync within %syncreg19.i.i.i516, label %sync.continue.i.i

sync.continue.i.i:                                ; preds = %pfor.cond.cleanup.i.i
  invoke void @llvm.sync.unwind(token %syncreg19.i.i.i516)
          to label %_ZN6parlay12parallel_forIZNS_8sequenceI7simplexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEmEUlmE_EEvmmT_mb.exit.i unwind label %lpad.i47

_ZN6parlay12parallel_forIZNS_8sequenceI7simplexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEmEUlmE_EEvmmT_mb.exit.i: ; preds = %sync.continue.i.i
  %bf.load.i.i6.i = load i8, i8* %small_n.i.i.i.i44, align 2
  %cmp.i.i7.i = icmp sgt i8 %bf.load.i.i6.i, -1
  br i1 %cmp.i.i7.i, label %if.then.i9.i, label %if.else.i10.i

if.then.i9.i:                                     ; preds = %_ZN6parlay12parallel_forIZNS_8sequenceI7simplexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEmEUlmE_EEvmmT_mb.exit.i
  %conv.i.i506 = trunc i64 %add to i8
  %bf.value.i.i507 = and i8 %conv.i.i506, 127
  %bf.clear.i.i508 = and i8 %bf.load.i.i6.i, -128
  %bf.set.i8.i = or i8 %bf.clear.i.i508, %bf.value.i.i507
  store i8 %bf.set.i8.i, i8* %small_n.i.i.i.i44, align 2
  br label %invoke.cont4

if.else.i10.i:                                    ; preds = %_ZN6parlay12parallel_forIZNS_8sequenceI7simplexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEmEUlmE_EEvmmT_mb.exit.i
  %29 = trunc i64 %add to i48
  store i48 %29, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i496, align 8
  br label %invoke.cont4

lpad.i47:                                         ; preds = %sync.continue.i.i, %call.i.i.i.i.i.i.noexc512, %_ZNK6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl8capacityEv.exit.i.i
  %30 = landingpad { i8*, i32 }
          cleanup
  %bf.load.i.i.i.i.i45 = load i8, i8* %small_n.i.i.i.i44, align 2
  %cmp.i.i.i.i.i46 = icmp sgt i8 %bf.load.i.i.i.i.i45, -1
  br i1 %cmp.i.i.i.i.i46, label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i, label %if.then.i.i.i.i51

if.then.i.i.i.i51:                                ; preds = %lpad.i47
  %buffer.i.i.i.i.i48 = getelementptr inbounds %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972", %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %31 = load %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"*, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i.i48, align 8, !tbaa !27
  %capacity.i.i.i.i.i.i49 = getelementptr inbounds %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965", %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %31, i64 0, i32 0
  %32 = load i64, i64* %capacity.i.i.i.i.i.i49, align 8, !tbaa !10
  %call.i.i.i.i.i1.i.i.i50 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i54 unwind label %lpad.i.i.i56

call.i.i.i.i.i.noexc.i.i.i54:                     ; preds = %if.then.i.i.i.i51
  %33 = bitcast %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %31 to i8*
  %mul.i.i.i.i.i.i52 = shl i64 %32, 4
  %add.i.i.i.i.i.i53 = or i64 %mul.i.i.i.i.i.i52, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i50, i8* %33, i64 %add.i.i.i.i.i.i53)
          to label %.noexc.i.i.i55 unwind label %lpad.i.i.i56

.noexc.i.i.i55:                                   ; preds = %call.i.i.i.i.i.noexc.i.i.i54
  store %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* null, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i.i48, align 8, !tbaa !27
  br label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i

lpad.i.i.i56:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.i54, %if.then.i.i.i.i51
  %34 = landingpad { i8*, i32 }
          catch i8* null
  %35 = extractvalue { i8*, i32 } %34, 0
  call void @__clang_call_terminate(i8* %35) #17
  unreachable

_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i: ; preds = %.noexc.i.i.i55, %lpad.i47
  store i8 0, i8* %small_n.i.i.i.i44, align 2
  %36 = extractvalue { i8*, i32 } %30, 0
  %37 = extractvalue { i8*, i32 } %30, 1
  br label %ehcleanup93

invoke.cont4:                                     ; preds = %if.else.i10.i, %if.then.i9.i
  %38 = bitcast %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %38) #16
  %small_n.i.i.i.i58 = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 0, i8* %small_n.i.i.i.i58, align 2
  invoke void @_ZN6parlay8sequenceIbNS_9allocatorIbEEE18initialize_defaultEm(%"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* nonnull %flags, i64 %add)
          to label %if.then.i.i.i.i73 unwind label %lpad.i61

lpad.i61:                                         ; preds = %invoke.cont4
  %39 = landingpad { i8*, i32 }
          cleanup
  %bf.load.i.i.i.i.i59 = load i8, i8* %small_n.i.i.i.i58, align 2
  %cmp.i.i.i.i.i60 = icmp sgt i8 %bf.load.i.i.i.i.i59, -1
  br i1 %cmp.i.i.i.i.i60, label %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit.i, label %if.then.i.i.i.i65

if.then.i.i.i.i65:                                ; preds = %lpad.i61
  %buffer.i.i.i.i.i62 = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %40 = load %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"*, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i.i62, align 8, !tbaa !29
  %capacity.i.i.i.i.i.i63 = getelementptr inbounds %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029", %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %40, i64 0, i32 0
  %41 = load i64, i64* %capacity.i.i.i.i.i.i63, align 8, !tbaa !31
  %call.i.i.i.i.i1.i.i.i64 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i67 unwind label %lpad.i.i.i69

call.i.i.i.i.i.noexc.i.i.i67:                     ; preds = %if.then.i.i.i.i65
  %42 = bitcast %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %40 to i8*
  %add.i.i.i.i.i.i66 = add i64 %41, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i64, i8* %42, i64 %add.i.i.i.i.i.i66)
          to label %.noexc.i.i.i68 unwind label %lpad.i.i.i69

.noexc.i.i.i68:                                   ; preds = %call.i.i.i.i.i.noexc.i.i.i67
  store %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* null, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i.i62, align 8, !tbaa !29
  br label %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit.i

lpad.i.i.i69:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.i67, %if.then.i.i.i.i65
  %43 = landingpad { i8*, i32 }
          catch i8* null
  %44 = extractvalue { i8*, i32 } %43, 0
  call void @__clang_call_terminate(i8* %44) #17
  unreachable

_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit.i: ; preds = %.noexc.i.i.i68, %lpad.i61
  store i8 0, i8* %small_n.i.i.i.i58, align 2
  %45 = extractvalue { i8*, i32 } %39, 0
  %46 = extractvalue { i8*, i32 } %39, 1
  br label %ehcleanup91

if.then.i.i.i.i73:                                ; preds = %invoke.cont4
  %47 = bitcast %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %47) #16
  %48 = getelementptr inbounds %class.anon.48.169.479.786.1093.1400.1707.2014, %class.anon.48.169.479.786.1093.1400.1707.2014* %ref.tmp, i64 0, i32 0
  call void @llvm.lifetime.start.p0i8(i64 1, i8* nonnull %48) #16
  %small_n.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 1
  store i8 -128, i8* %small_n.i.i.i.i.i.i, align 2, !alias.scope !33
  %call.i.i.i.i.i1.i.i.i72 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i76 unwind label %lpad.i.i.i78

call.i.i.i.i.i.noexc.i.i.i76:                     ; preds = %if.then.i.i.i.i73
  %mul.i.i.i.i.i.i74 = mul nuw nsw i64 %add, 48
  %add.i.i.i.i.i.i75 = or i64 %mul.i.i.i.i.i.i74, 8
  %call2.i.i.i.i.i2.i.i.i = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i72, i64 %add.i.i.i.i.i.i75)
          to label %invoke.cont.i.i.i unwind label %lpad.i.i.i78

invoke.cont.i.i.i:                                ; preds = %call.i.i.i.i.i.noexc.i.i.i76
  %capacity.i.i.i3.i.i.i.i = bitcast i8* %call2.i.i.i.i.i2.i.i.i to i64*
  store i64 %add, i64* %capacity.i.i.i3.i.i.i.i, align 8, !tbaa !38
  %49 = bitcast %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ to i8**
  store i8* %call2.i.i.i.i.i2.i.i.i, i8** %49, align 8, !tbaa.struct !12, !alias.scope !33
  %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i.i.i to i48*
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i, align 8, !tbaa.struct !12, !alias.scope !33
  %bf.load.i.i.i.pr.i.i = load i8, i8* %small_n.i.i.i.i.i.i, align 2, !alias.scope !33
  %cmp.i.i.i.i.i77 = icmp sgt i8 %bf.load.i.i.i.pr.i.i, -1
  br i1 %cmp.i.i.i.i.i77, label %invoke.cont3.i.i.i, label %invoke.cont3.i.thread.i.i

invoke.cont3.i.thread.i.i:                        ; preds = %invoke.cont.i.i.i
  %50 = trunc i64 %add to i48
  store i48 %50, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i, align 8, !alias.scope !33
  %51 = bitcast %struct.Qs.63.374.681.988.1295.1602.1909** %buffer.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %51) #16, !noalias !33
  br label %if.else.i9.i.i.i

invoke.cont3.i.i.i:                               ; preds = %invoke.cont.i.i.i
  %conv.i.i.i.i = trunc i64 %add to i8
  %bf.value.i.i.i.i = and i8 %conv.i.i.i.i, 127
  %bf.clear.i.i.i.i = and i8 %bf.load.i.i.i.pr.i.i, -128
  %bf.set.i3.i.i.i = or i8 %bf.clear.i.i.i.i, %bf.value.i.i.i.i
  store i8 %bf.set.i3.i.i.i, i8* %small_n.i.i.i.i.i.i, align 2, !alias.scope !33
  %52 = bitcast %struct.Qs.63.374.681.988.1295.1602.1909** %buffer.i.i.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %52) #16, !noalias !33
  %cmp.i.i7.i.i.i = icmp sgt i8 %bf.set.i3.i.i.i, -1
  br i1 %cmp.i.i7.i.i.i, label %if.then.i8.i.i.i, label %if.else.i9.i.i.i

if.then.i8.i.i.i:                                 ; preds = %invoke.cont3.i.i.i
  %53 = bitcast %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ to %struct.Qs.63.374.681.988.1295.1602.1909*
  br label %invoke.cont6.i.i.i

if.else.i9.i.i.i:                                 ; preds = %invoke.cont3.i.i.i, %invoke.cont3.i.thread.i.i
  %54 = phi i8* [ %51, %invoke.cont3.i.thread.i.i ], [ %52, %invoke.cont3.i.i.i ]
  %data.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %call2.i.i.i.i.i2.i.i.i, i64 8
  %55 = bitcast i8* %data.i.i.i.i.i.i.i to %struct.Qs.63.374.681.988.1295.1602.1909*
  br label %invoke.cont6.i.i.i

invoke.cont6.i.i.i:                               ; preds = %if.else.i9.i.i.i, %if.then.i8.i.i.i
  %56 = phi i8* [ %52, %if.then.i8.i.i.i ], [ %54, %if.else.i9.i.i.i ]
  %retval.0.i.i.i.i = phi %struct.Qs.63.374.681.988.1295.1602.1909* [ %53, %if.then.i8.i.i.i ], [ %55, %if.else.i9.i.i.i ]
  store %struct.Qs.63.374.681.988.1295.1602.1909* %retval.0.i.i.i.i, %struct.Qs.63.374.681.988.1295.1602.1909** %buffer.i.i.i, align 8, !tbaa !13, !noalias !33
  invoke fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceI2QsI7point2dIdEENS_9allocatorIS5_EEEC1IRZ24incrementally_add_pointsNS1_IP6vertexIS4_ENS6_ISC_EEEESC_E3$_3EEmOT_NS8_18_from_function_tagEmEUlmE_EEvmmSH_mb"(i64 %add, %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* nonnull %VQ, %struct.Qs.63.374.681.988.1295.1602.1909** nonnull %buffer.i.i.i, %class.anon.48.169.479.786.1093.1400.1707.2014* nonnull %ref.tmp)
          to label %invoke.cont10 unwind label %lpad5.i.i.i

lpad.i.i.i78:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.i76, %if.then.i.i.i.i73
  %57 = landingpad { i8*, i32 }
          cleanup
  %58 = extractvalue { i8*, i32 } %57, 0
  %59 = extractvalue { i8*, i32 } %57, 1
  br label %ehcleanup.i.i.i.tf

lpad5.i.i.i:                                      ; preds = %invoke.cont6.i.i.i
  %60 = landingpad { i8*, i32 }
          cleanup
  %61 = extractvalue { i8*, i32 } %60, 0
  %62 = extractvalue { i8*, i32 } %60, 1
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %56) #16, !noalias !33
  br label %ehcleanup.i.i.i.tf

ehcleanup.i.i.i.tf:                               ; preds = %lpad5.i.i.i, %lpad.i.i.i78
  %exn.slot.0.i.i.i = phi i8* [ %61, %lpad5.i.i.i ], [ %58, %lpad.i.i.i78 ]
  %ehselector.slot.0.i.i.i = phi i32 [ %62, %lpad5.i.i.i ], [ %59, %lpad.i.i.i78 ]
  %bf.load.i.i518 = load i8, i8* %small_n.i.i.i.i.i.i, align 2
  %cmp.i.i519 = icmp sgt i8 %bf.load.i.i518, -1
  br i1 %cmp.i.i519, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i.i.i, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i526

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i526: ; preds = %ehcleanup.i.i.i.tf
  %n.i.i.i.i520 = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %63 = bitcast [6 x i8]* %n.i.i.i.i520 to i48*
  %bf.load.i1.i.i.i521 = load i48, i48* %63, align 8
  %bf.cast.i.i.i.i522 = zext i48 %bf.load.i1.i.i.i521 to i64
  %buffer.i.i.i.i.i523 = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %64 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i523, align 8, !tbaa !40
  %data.i.i.i.i.i.i524 = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %64, i64 0, i32 1, i32 0
  %65 = bitcast [1 x i8]* %data.i.i.i.i.i.i524 to %struct.Qs.63.374.681.988.1295.1602.1909*
  %cmp1.i.i.i525 = icmp eq i48 %bf.load.i1.i.i.i521, 0
  br i1 %cmp1.i.i.i525, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i548, label %pfor.cond.i.i.i529.preheader

pfor.cond.i.i.i529.preheader:                     ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i526
  %66 = add nsw i64 %bf.cast.i.i.i.i522, -1
  %xtraiter14 = and i64 %bf.cast.i.i.i.i522, 2047
  %67 = icmp ult i64 %66, 2047
  br i1 %67, label %pfor.cond.cleanup.i.i.i542.strpm-lcssa, label %pfor.cond.i.i.i529.preheader.new

pfor.cond.i.i.i529.preheader.new:                 ; preds = %pfor.cond.i.i.i529.preheader
  %stripiter17 = lshr i64 %bf.cast.i.i.i.i522, 11
  br label %pfor.cond.i.i.i529.strpm.outer

pfor.cond.i.i.i529.strpm.outer:                   ; preds = %pfor.inc.i.i.i541.strpm.outer, %pfor.cond.i.i.i529.preheader.new
  %niter18 = phi i64 [ 0, %pfor.cond.i.i.i529.preheader.new ], [ %niter18.nadd, %pfor.inc.i.i.i541.strpm.outer ]
  detach within %syncreg19.i.i.i516, label %pfor.body.i.i.i532.strpm.outer, label %pfor.inc.i.i.i541.strpm.outer

pfor.body.i.i.i532.strpm.outer:                   ; preds = %pfor.cond.i.i.i529.strpm.outer
  %68 = shl i64 %niter18, 11
  br label %pfor.cond.i.i.i529

pfor.cond.i.i.i529:                               ; preds = %pfor.inc.i.i.i541, %pfor.body.i.i.i532.strpm.outer
  %__begin.0.i.i.i528 = phi i64 [ %inc.i.i.i539, %pfor.inc.i.i.i541 ], [ %68, %pfor.body.i.i.i532.strpm.outer ]
  %inneriter19 = phi i64 [ %inneriter19.nsub, %pfor.inc.i.i.i541 ], [ 2048, %pfor.body.i.i.i532.strpm.outer ]
  %_M_start.i.i.i.i.i.i.i.i.i.i.i530 = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %65, i64 %__begin.0.i.i.i528, i32 1, i32 0, i32 0, i32 0, i32 0
  %69 = load %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904** %_M_start.i.i.i.i.i.i.i.i.i.i.i530, align 8, !tbaa !42
  %tobool.i.i.i.i.i.i.i.i.i.i.i.i531 = icmp eq %struct.simplex.58.369.676.983.1290.1597.1904* %69, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i.i.i531, label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536, label %if.then.i.i.i.i.i.i.i.i.i.i.i.i533

if.then.i.i.i.i.i.i.i.i.i.i.i.i533:               ; preds = %pfor.cond.i.i.i529
  %70 = bitcast %struct.simplex.58.369.676.983.1290.1597.1904* %69 to i8*
  call void @_ZdlPv(i8* nonnull %70) #16
  br label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536

_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i.i533, %pfor.cond.i.i.i529
  %_M_start.i.i1.i.i.i.i.i.i.i.i.i534 = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %65, i64 %__begin.0.i.i.i528, i32 0, i32 0, i32 0, i32 0, i32 0
  %71 = load %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898*** %_M_start.i.i1.i.i.i.i.i.i.i.i.i534, align 8, !tbaa !44
  %tobool.i.i.i2.i.i.i.i.i.i.i.i.i535 = icmp eq %struct.vertex.52.363.670.977.1284.1591.1898** %71, null
  br i1 %tobool.i.i.i2.i.i.i.i.i.i.i.i.i535, label %pfor.inc.i.i.i541, label %if.then.i.i.i3.i.i.i.i.i.i.i.i.i537

if.then.i.i.i3.i.i.i.i.i.i.i.i.i537:              ; preds = %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536
  %72 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %71 to i8*
  call void @_ZdlPv(i8* nonnull %72) #16
  br label %pfor.inc.i.i.i541

pfor.inc.i.i.i541:                                ; preds = %if.then.i.i.i3.i.i.i.i.i.i.i.i.i537, %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536
  %inc.i.i.i539 = add nuw nsw i64 %__begin.0.i.i.i528, 1
  %inneriter19.nsub = add nsw i64 %inneriter19, -1
  %inneriter19.ncmp = icmp eq i64 %inneriter19.nsub, 0
  br i1 %inneriter19.ncmp, label %pfor.inc.i.i.i541.reattach, label %pfor.cond.i.i.i529, !llvm.loop !46

pfor.inc.i.i.i541.reattach:                       ; preds = %pfor.inc.i.i.i541
  reattach within %syncreg19.i.i.i516, label %pfor.inc.i.i.i541.strpm.outer

pfor.inc.i.i.i541.strpm.outer:                    ; preds = %pfor.inc.i.i.i541.reattach, %pfor.cond.i.i.i529.strpm.outer
  %niter18.nadd = add nuw nsw i64 %niter18, 1
  %niter18.ncmp = icmp eq i64 %niter18.nadd, %stripiter17
  br i1 %niter18.ncmp, label %pfor.cond.cleanup.i.i.i542.strpm-lcssa, label %pfor.cond.i.i.i529.strpm.outer, !llvm.loop !47

pfor.cond.cleanup.i.i.i542.strpm-lcssa:           ; preds = %pfor.inc.i.i.i541.strpm.outer, %pfor.cond.i.i.i529.preheader
  %lcmp.mod20 = icmp eq i64 %xtraiter14, 0
  br i1 %lcmp.mod20, label %pfor.cond.cleanup.i.i.i542, label %pfor.cond.i.i.i529.epil.preheader

pfor.cond.i.i.i529.epil.preheader:                ; preds = %pfor.cond.cleanup.i.i.i542.strpm-lcssa
  %73 = and i64 %bf.cast.i.i.i.i522, 281474976708608
  br label %pfor.cond.i.i.i529.epil

pfor.cond.i.i.i529.epil:                          ; preds = %pfor.inc.i.i.i541.epil, %pfor.cond.i.i.i529.epil.preheader
  %__begin.0.i.i.i528.epil = phi i64 [ %inc.i.i.i539.epil, %pfor.inc.i.i.i541.epil ], [ %73, %pfor.cond.i.i.i529.epil.preheader ]
  %epil.iter15 = phi i64 [ %epil.iter15.sub, %pfor.inc.i.i.i541.epil ], [ %xtraiter14, %pfor.cond.i.i.i529.epil.preheader ]
  %_M_start.i.i.i.i.i.i.i.i.i.i.i530.epil = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %65, i64 %__begin.0.i.i.i528.epil, i32 1, i32 0, i32 0, i32 0, i32 0
  %74 = load %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904** %_M_start.i.i.i.i.i.i.i.i.i.i.i530.epil, align 8, !tbaa !42
  %tobool.i.i.i.i.i.i.i.i.i.i.i.i531.epil = icmp eq %struct.simplex.58.369.676.983.1290.1597.1904* %74, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i.i.i531.epil, label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536.epil, label %if.then.i.i.i.i.i.i.i.i.i.i.i.i533.epil

if.then.i.i.i.i.i.i.i.i.i.i.i.i533.epil:          ; preds = %pfor.cond.i.i.i529.epil
  %75 = bitcast %struct.simplex.58.369.676.983.1290.1597.1904* %74 to i8*
  call void @_ZdlPv(i8* nonnull %75) #16
  br label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536.epil

_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536.epil: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i.i533.epil, %pfor.cond.i.i.i529.epil
  %_M_start.i.i1.i.i.i.i.i.i.i.i.i534.epil = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %65, i64 %__begin.0.i.i.i528.epil, i32 0, i32 0, i32 0, i32 0, i32 0
  %76 = load %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898*** %_M_start.i.i1.i.i.i.i.i.i.i.i.i534.epil, align 8, !tbaa !44
  %tobool.i.i.i2.i.i.i.i.i.i.i.i.i535.epil = icmp eq %struct.vertex.52.363.670.977.1284.1591.1898** %76, null
  br i1 %tobool.i.i.i2.i.i.i.i.i.i.i.i.i535.epil, label %pfor.inc.i.i.i541.epil, label %if.then.i.i.i3.i.i.i.i.i.i.i.i.i537.epil

if.then.i.i.i3.i.i.i.i.i.i.i.i.i537.epil:         ; preds = %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536.epil
  %77 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %76 to i8*
  call void @_ZdlPv(i8* nonnull %77) #16
  br label %pfor.inc.i.i.i541.epil

pfor.inc.i.i.i541.epil:                           ; preds = %if.then.i.i.i3.i.i.i.i.i.i.i.i.i537.epil, %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i536.epil
  %inc.i.i.i539.epil = add nuw nsw i64 %__begin.0.i.i.i528.epil, 1
  %epil.iter15.sub = add nsw i64 %epil.iter15, -1
  %epil.iter15.cmp = icmp eq i64 %epil.iter15.sub, 0
  br i1 %epil.iter15.cmp, label %pfor.cond.cleanup.i.i.i542, label %pfor.cond.i.i.i529.epil, !llvm.loop !48

pfor.cond.cleanup.i.i.i542:                       ; preds = %pfor.inc.i.i.i541.epil, %pfor.cond.cleanup.i.i.i542.strpm-lcssa
  sync within %syncreg19.i.i.i516, label %sync.continue.i.i.i543

sync.continue.i.i.i543:                           ; preds = %pfor.cond.cleanup.i.i.i542
  invoke void @llvm.sync.unwind(token %syncreg19.i.i.i516)
          to label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i548 unwind label %lpad.i.i.i.i.i551

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i548: ; preds = %sync.continue.i.i.i543, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i526
  %78 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i523, align 8, !tbaa !40
  %capacity.i.i.i545 = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %78, i64 0, i32 0
  %79 = load i64, i64* %capacity.i.i.i545, align 8, !tbaa !38
  %call.i.i.i.i.i555 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc554 unwind label %lpad.i.i.i.i.i551

call.i.i.i.i.i.noexc554:                          ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i548
  %80 = bitcast %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %78 to i8*
  %mul.i.i.i546 = mul i64 %79, 48
  %add.i.i.i547 = or i64 %mul.i.i.i546, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i555, i8* %80, i64 %add.i.i.i547)
          to label %.noexc556 unwind label %lpad.i.i.i.i.i551

.noexc556:                                        ; preds = %call.i.i.i.i.i.noexc554
  store %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* null, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i523, align 8, !tbaa !40
  br label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i.i.i

lpad.i.i.i.i.i551:                                ; preds = %call.i.i.i.i.i.noexc554, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i548, %sync.continue.i.i.i543
  %81 = landingpad { i8*, i32 }
          catch i8* null
  %82 = extractvalue { i8*, i32 } %81, 0
  call void @__clang_call_terminate(i8* %82) #17
  unreachable

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i.i.i: ; preds = %.noexc556, %ehcleanup.i.i.i.tf
  store i8 0, i8* %small_n.i.i.i.i.i.i, align 2
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %48) #16
  br label %ehcleanup89

invoke.cont10:                                    ; preds = %invoke.cont6.i.i.i
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %56) #16, !noalias !33
  call void @llvm.lifetime.end.p0i8(i64 1, i8* nonnull %48) #16
  %83 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %init to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %83) #16
  %small_n.i.i.i.i80 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %init, i64 0, i32 0, i32 0, i32 0, i32 1
  %84 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %init to i64*
  store i64 %0, i64* %84, align 8, !tbaa !13
  store i8 1, i8* %small_n.i.i.i.i80, align 2
  %85 = bitcast %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %knn to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %85) #16
  %tree.i = getelementptr inbounds %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963, %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %knn, i64 0, i32 0
  %_M_head_impl.i.i.i.i.i.i.i = getelementptr inbounds %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963, %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %knn, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* null, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %_M_head_impl.i.i.i.i.i.i.i, align 8, !tbaa !49
  %86 = bitcast %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* %ref.tmp.i to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %86) #16
  invoke void @_ZN8oct_treeI6vertexI7point2dIdEEE5buildIN6parlay8sequenceIPS3_NS6_9allocatorIS8_EEEEEESt10unique_ptrINS4_4nodeENS4_11delete_treeEERT_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull sret %ref.tmp.i, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* nonnull dereferenceable(15) %init)
          to label %invoke.cont12 unwind label %lpad.i95

lpad.i95:                                         ; preds = %invoke.cont10
  %87 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %86) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i) #16
  %88 = extractvalue { i8*, i32 } %87, 0
  %89 = extractvalue { i8*, i32 } %87, 1
  br label %ehcleanup85

invoke.cont12:                                    ; preds = %invoke.cont10
  %call.i = call dereferenceable(8) %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEEaSEOS8_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i, %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull dereferenceable(8) %ref.tmp.i) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %ref.tmp.i) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %86) #16
  %90 = bitcast i64* %num_done to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %90) #16
  store i64 0, i64* %num_done, align 8, !tbaa !14
  %91 = bitcast i64* %num_remain to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %91) #16
  store i64 0, i64* %num_remain, align 8, !tbaa !14
  %cmp674 = icmp eq i64 %retval.0.i.i, 0
  br i1 %cmp674, label %while.end, label %while.body.lr.ph

while.body.lr.ph:                                 ; preds = %invoke.cont12
  %div14 = udiv i64 %retval.0.i.i, 10
  %92 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs to i8*
  %93 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done to %struct.vertex.52.363.670.977.1284.1591.1898**
  %buffer.i.i.i.i.i100 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %small_n.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs, i64 0, i32 0, i32 0, i32 0, i32 1
  %94 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898*** %first.addr.i to i8*
  %95 = bitcast %class.anon.262.282.589.896.1203.1510.1817.2124* %agg.tmp.i to i8*
  %96 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs to i8**
  %ref.tmp.sroa.4.0..sroa_idx5.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %ref.tmp.sroa.4.0..sroa_cast6.i.i = bitcast [6 x i8]* %ref.tmp.sroa.4.0..sroa_idx5.i.i to i48*
  %97 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898*** %buffer.i to i8*
  %98 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs to %struct.vertex.52.363.670.977.1284.1591.1898**
  %buffer.i.i.i.i109 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %99 = getelementptr inbounds %class.anon.262.282.589.896.1203.1510.1817.2124, %class.anon.262.282.589.896.1203.1510.1817.2124* %agg.tmp.i, i64 0, i32 0
  %100 = getelementptr inbounds %class.anon.262.282.589.896.1203.1510.1817.2124, %class.anon.262.282.589.896.1203.1510.1817.2124* %agg.tmp.i, i64 0, i32 1
  %101 = getelementptr inbounds %class.anon.262.282.589.896.1203.1510.1817.2124, %class.anon.262.282.589.896.1203.1510.1817.2124* %agg.tmp.i, i64 0, i32 2
  %102 = bitcast %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %ref.tmp21 to i8*
  %tree.i120 = getelementptr inbounds %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963, %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %ref.tmp21, i64 0, i32 0
  %_M_head_impl.i.i.i.i.i.i.i121 = getelementptr inbounds %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963, %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %ref.tmp21, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %103 = bitcast %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* %ref.tmp.i119 to i8*
  %104 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 0
  %105 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 1
  %106 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 2
  %107 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 3
  %108 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 4
  %109 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 5
  %110 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 6
  %111 = getelementptr inbounds %class.anon.52.136.447.754.1061.1368.1675.1982, %class.anon.52.136.447.754.1061.1368.1675.1982* %agg.tmp, i64 0, i32 7
  %112 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer to %struct.vertex.52.363.670.977.1284.1591.1898**
  %buffer.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %113 = bitcast %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ to %struct.Qs.63.374.681.988.1295.1602.1909*
  %buffer.i.i.i.i.i26.i.i = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %buffer.i.i.i.i.i9.i.i = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %114 = bitcast %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp.i186 to i8*
  %115 = bitcast %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp.i186 to i64*
  %116 = getelementptr inbounds %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp.i186, i64 0, i32 1
  %117 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898*** %116 to i64*
  %118 = bitcast %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"* %ref.tmp1.i to i8*
  %119 = bitcast %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"* %ref.tmp1.i to i64*
  %120 = getelementptr inbounds %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016", %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"* %ref.tmp1.i, i64 0, i32 1
  %121 = bitcast i8** %120 to i64*
  %122 = getelementptr inbounds [15 x i8], [15 x i8]* %tmp.i.i.i, i64 0, i64 0
  %123 = bitcast %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %agg.tmp40 to i8*
  %flag.i.i.i.i188 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %agg.tmp40, i64 0, i32 0, i32 0, i32 0, i32 1
  %buffer.i.i.i.i191 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %agg.tmp40, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %n.i.i.i206 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %remain, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %124 = bitcast [6 x i8]* %n.i.i.i206 to i48*
  %125 = bitcast %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags to i8*
  %126 = ptrtoint %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags to i64
  %first.i.i = getelementptr inbounds %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127", %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags, i64 0, i32 0
  %last.i.i = getelementptr inbounds %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127", %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags, i64 0, i32 1
  %f.i.i = getelementptr inbounds %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127", %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags, i64 0, i32 2
  %127 = bitcast %class.anon.55.284.591.898.1205.1512.1819.2126* %f.i.i to i64*
  %128 = bitcast %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp62 to i8*
  %129 = getelementptr inbounds %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp62, i64 0, i32 0
  %130 = getelementptr inbounds %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp62, i64 0, i32 1
  %131 = bitcast %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %Out.i to i8*
  %132 = getelementptr inbounds %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %Out.i, i64 0, i32 0
  %133 = getelementptr inbounds %"struct.parlay::slice.170.480.787.1094.1401.1708.2015", %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %Out.i, i64 0, i32 1
  %134 = bitcast i64* %l.i to i8*
  %135 = bitcast %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i to i8*
  %small_n.i.i.i.i.i246 = getelementptr inbounds %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927", %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %136 = bitcast %class.anon.264.286.593.900.1207.1514.1821.2128* %ref.tmp6.i to i8*
  %137 = getelementptr inbounds %class.anon.264.286.593.900.1207.1514.1821.2128, %class.anon.264.286.593.900.1207.1514.1821.2128* %ref.tmp6.i, i64 0, i32 0
  %138 = getelementptr inbounds %class.anon.264.286.593.900.1207.1514.1821.2128, %class.anon.264.286.593.900.1207.1514.1821.2128* %ref.tmp6.i, i64 0, i32 1
  %139 = bitcast i64* %n.addr.i.i to i8*
  %140 = bitcast i64* %block_size.addr.i.i to i8*
  %141 = bitcast i64* %m.i to i8*
  %142 = bitcast %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i to i64*
  %buffer.i.i.i.i.i.i.i259 = getelementptr inbounds %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927", %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %n.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927", %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %143 = bitcast [6 x i8]* %n.i.i.i.i.i.i to i48*
  %144 = bitcast %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"* %In.i.i to i8*
  %145 = bitcast %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* %m.i.i to i8*
  %146 = getelementptr inbounds %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019", %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"* %In.i.i, i64 0, i32 0
  %147 = getelementptr inbounds %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019", %"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"* %In.i.i, i64 0, i32 1
  %coerce.dive.i.i = getelementptr inbounds %"struct.parlay::addm.154.465.772.1079.1386.1693.2000", %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* %m.i.i, i64 0, i32 0
  %148 = bitcast %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i to i8*
  %149 = getelementptr inbounds %class.anon.265.287.594.901.1208.1515.1822.2129, %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i, i64 0, i32 0
  %150 = getelementptr inbounds %class.anon.265.287.594.901.1208.1515.1822.2129, %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i, i64 0, i32 1
  %151 = getelementptr inbounds %class.anon.265.287.594.901.1208.1515.1822.2129, %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i, i64 0, i32 2
  %152 = getelementptr inbounds %class.anon.265.287.594.901.1208.1515.1822.2129, %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i, i64 0, i32 3
  %153 = getelementptr inbounds %class.anon.265.287.594.901.1208.1515.1822.2129, %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i, i64 0, i32 4
  %154 = getelementptr inbounds %class.anon.265.287.594.901.1208.1515.1822.2129, %class.anon.265.287.594.901.1208.1515.1822.2129* %ref.tmp15.i, i64 0, i32 5
  %155 = bitcast i64* %n.addr.i25.i to i8*
  %156 = bitcast i64* %block_size.addr.i26.i to i8*
  %f.idx.i.i.i.i = getelementptr inbounds %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127", %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags, i64 0, i32 2, i32 0
  br label %while.body

while.body:                                       ; preds = %invoke.cont70, %while.body.lr.ph
  %157 = phi i64 [ 0, %while.body.lr.ph ], [ %add74, %invoke.cont70 ]
  %num_next_rebuild.0675 = phi i64 [ 100, %while.body.lr.ph ], [ %num_next_rebuild.1, %invoke.cont70 ]
  %cmp13 = icmp ult i64 %157, %num_next_rebuild.0675
  %cmp15 = icmp ugt i64 %157, %div14
  %or.cond = or i1 %cmp13, %cmp15
  br i1 %or.cond, label %if.end, label %if.then

if.then:                                          ; preds = %while.body
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %92) #16
  %bf.load.i.i.i.i98 = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i99 = icmp sgt i8 %bf.load.i.i.i.i98, -1
  %158 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i100, align 8
  %data.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %158, i64 0, i32 1, i32 0
  %159 = bitcast [1 x i8]* %data.i.i.i.i.i.i to %struct.vertex.52.363.670.977.1284.1591.1898**
  %.pn.i = select i1 %cmp.i.i.i.i99, %struct.vertex.52.363.670.977.1284.1591.1898** %93, %struct.vertex.52.363.670.977.1284.1591.1898** %159
  store i8 0, i8* %small_n.i.i.i.i.i, align 2, !alias.scope !51
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %94)
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %95)
  store %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i, %struct.vertex.52.363.670.977.1284.1591.1898*** %first.addr.i, align 8, !tbaa !13
  %cmp.i.i = icmp ugt i64 %157, 1
  br i1 %cmp.i.i, label %if.then.i6.i, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i.thread

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i.thread: ; preds = %if.then
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %97) #16
  br label %161

if.then.i6.i:                                     ; preds = %if.then
  store i8 -128, i8* %small_n.i.i.i.i.i, align 2
  %call.i.i.i.i.i.i117 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.i.noexc unwind label %lpad.i.i101

call.i.i.i.i.i.i.noexc:                           ; preds = %if.then.i6.i
  %add.ptr3.i.idx = shl i64 %157, 3
  %add.i.i.i.i = add i64 %add.ptr3.i.idx, 8
  %call2.i.i.i.i.i.i118 = invoke i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i.i117, i64 %add.i.i.i.i)
          to label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i unwind label %lpad.i.i101

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i: ; preds = %call.i.i.i.i.i.i.noexc
  %capacity.i.i.i3.i.i = bitcast i8* %call2.i.i.i.i.i.i118 to i64*
  store i64 %157, i64* %capacity.i.i.i3.i.i, align 8, !tbaa !7
  store i8* %call2.i.i.i.i.i.i118, i8** %96, align 8, !tbaa.struct !12
  store i48 0, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i, align 8, !tbaa.struct !12
  %bf.load.i.i8.i.pre = load i8, i8* %small_n.i.i.i.i.i, align 2
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %97) #16
  %cmp.i.i9.i = icmp sgt i8 %bf.load.i.i8.i.pre, -1
  %data.i.i.i.i.i = getelementptr inbounds i8, i8* %call2.i.i.i.i.i.i118, i64 8
  %160 = bitcast i8* %data.i.i.i.i.i to %struct.vertex.52.363.670.977.1284.1591.1898**
  br i1 %cmp.i.i9.i, label %161, label %162

161:                                              ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i.thread
  br label %162

162:                                              ; preds = %161, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i
  %163 = phi %struct.vertex.52.363.670.977.1284.1591.1898** [ %98, %161 ], [ %160, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl19initialize_capacityEm.exit.i ]
  store %struct.vertex.52.363.670.977.1284.1591.1898** %163, %struct.vertex.52.363.670.977.1284.1591.1898*** %buffer.i, align 8, !tbaa !13
  store %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %vtxs, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"** %99, align 8, !tbaa !54
  store %struct.vertex.52.363.670.977.1284.1591.1898*** %buffer.i, %struct.vertex.52.363.670.977.1284.1591.1898**** %100, align 8, !tbaa !13
  store %struct.vertex.52.363.670.977.1284.1591.1898*** %first.addr.i, %struct.vertex.52.363.670.977.1284.1591.1898**** %101, align 8, !tbaa !13
  invoke void @_ZN6parlay12parallel_forIZNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEE16initialize_rangeIPS6_EEvT_SC_St26random_access_iterator_tagEUlmE_EEvmmSC_mb(i64 0, i64 %157, %class.anon.262.282.589.896.1203.1510.1817.2124* nonnull byval(%class.anon.262.282.589.896.1203.1510.1817.2124) align 8 %agg.tmp.i, i64 1025, i1 zeroext false)
          to label %.noexc unwind label %lpad.i.i101

.noexc:                                           ; preds = %162
  %bf.load.i.i.i111 = load i8, i8* %small_n.i.i.i.i.i, align 2
  %cmp.i.i.i112 = icmp sgt i8 %bf.load.i.i.i111, -1
  br i1 %cmp.i.i.i112, label %if.then.i.i114, label %if.else.i.i116

if.then.i.i114:                                   ; preds = %.noexc
  %conv.i.i113 = trunc i64 %157 to i8
  %bf.value.i.i = and i8 %conv.i.i113, 127
  %bf.clear.i.i = and i8 %bf.load.i.i.i111, -128
  %bf.set.i.i = or i8 %bf.clear.i.i, %bf.value.i.i
  store i8 %bf.set.i.i, i8* %small_n.i.i.i.i.i, align 2
  br label %invoke.cont20

if.else.i.i116:                                   ; preds = %.noexc
  %164 = trunc i64 %157 to i48
  store i48 %164, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i, align 8
  br label %invoke.cont20

lpad.i.i101:                                      ; preds = %162, %call.i.i.i.i.i.i.noexc, %if.then.i6.i
  %165 = landingpad { i8*, i32 }
          cleanup
  %bf.load.i.i.i.i.i.i = load i8, i8* %small_n.i.i.i.i.i, align 2, !alias.scope !51
  %cmp.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i.i, label %if.then.i.i.i.i.i

if.then.i.i.i.i.i:                                ; preds = %lpad.i.i101
  %166 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i109, align 8, !tbaa !2, !alias.scope !51
  %capacity.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %166, i64 0, i32 0
  %167 = load i64, i64* %capacity.i.i.i.i.i.i.i, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i unwind label %lpad.i.i.i.i

call.i.i.i.i.i.noexc.i.i.i.i:                     ; preds = %if.then.i.i.i.i.i
  %168 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %166 to i8*
  %mul.i.i.i.i.i.i.i = shl i64 %167, 3
  %add.i.i.i.i.i.i.i = add i64 %mul.i.i.i.i.i.i.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i.i, i8* %168, i64 %add.i.i.i.i.i.i.i)
          to label %.noexc.i.i.i.i unwind label %lpad.i.i.i.i

.noexc.i.i.i.i:                                   ; preds = %call.i.i.i.i.i.noexc.i.i.i.i
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i109, align 8, !tbaa !2, !alias.scope !51
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i.i

lpad.i.i.i.i:                                     ; preds = %call.i.i.i.i.i.noexc.i.i.i.i, %if.then.i.i.i.i.i
  %169 = landingpad { i8*, i32 }
          catch i8* null
  %170 = extractvalue { i8*, i32 } %169, 0
  call void @__clang_call_terminate(i8* %170) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i.i: ; preds = %.noexc.i.i.i.i, %lpad.i.i101
  store i8 0, i8* %small_n.i.i.i.i.i, align 2, !alias.scope !51
  %171 = extractvalue { i8*, i32 } %165, 0
  %172 = extractvalue { i8*, i32 } %165, 1
  br label %ehcleanup

invoke.cont20:                                    ; preds = %if.else.i.i116, %if.then.i.i114
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %97) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %94)
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %95)
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %102) #16
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* null, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %_M_head_impl.i.i.i.i.i.i.i121, align 8, !tbaa !49
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %103) #16
  invoke void @_ZN8oct_treeI6vertexI7point2dIdEEE5buildIN6parlay8sequenceIPS3_NS6_9allocatorIS8_EEEEEESt10unique_ptrINS4_4nodeENS4_11delete_treeEERT_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull sret %ref.tmp.i119, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* nonnull dereferenceable(15) %vtxs)
          to label %invoke.cont23 unwind label %lpad.i123

lpad.i123:                                        ; preds = %invoke.cont20
  %173 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %103) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i120) #16
  %174 = extractvalue { i8*, i32 } %173, 0
  %175 = extractvalue { i8*, i32 } %173, 1
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %102) #16
  %bf.load.i.i.i.i143 = load i8, i8* %small_n.i.i.i.i.i, align 2
  %cmp.i.i.i.i144 = icmp sgt i8 %bf.load.i.i.i.i143, -1
  br i1 %cmp.i.i.i.i144, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit154, label %if.then.i.i.i148

invoke.cont23:                                    ; preds = %invoke.cont20
  %call.i122 = call dereferenceable(8) %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEEaSEOS8_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i120, %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull dereferenceable(8) %ref.tmp.i119) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %ref.tmp.i119) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %103) #16
  %call.i127 = call dereferenceable(8) %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEEaSEOS8_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i, %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull dereferenceable(8) %tree.i120) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i120) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %102) #16
  %mul = mul i64 %num_next_rebuild.0675, 10
  %bf.load.i.i.i.i130 = load i8, i8* %small_n.i.i.i.i.i, align 2
  %cmp.i.i.i.i131 = icmp sgt i8 %bf.load.i.i.i.i130, -1
  br i1 %cmp.i.i.i.i131, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit141, label %if.then.i.i.i135

if.then.i.i.i135:                                 ; preds = %invoke.cont23
  %176 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i109, align 8, !tbaa !2
  %capacity.i.i.i.i.i133 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %176, i64 0, i32 0
  %177 = load i64, i64* %capacity.i.i.i.i.i133, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i134 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i138 unwind label %lpad.i.i140

call.i.i.i.i.i.noexc.i.i138:                      ; preds = %if.then.i.i.i135
  %178 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %176 to i8*
  %mul.i.i.i.i.i136 = shl i64 %177, 3
  %add.i.i.i.i.i137 = add i64 %mul.i.i.i.i.i136, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i134, i8* %178, i64 %add.i.i.i.i.i137)
          to label %.noexc.i.i139 unwind label %lpad.i.i140

.noexc.i.i139:                                    ; preds = %call.i.i.i.i.i.noexc.i.i138
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i109, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit141

lpad.i.i140:                                      ; preds = %call.i.i.i.i.i.noexc.i.i138, %if.then.i.i.i135
  %179 = landingpad { i8*, i32 }
          catch i8* null
  %180 = extractvalue { i8*, i32 } %179, 0
  call void @__clang_call_terminate(i8* %180) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit141: ; preds = %.noexc.i.i139, %invoke.cont23
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %92) #16
  %.pre = load i64, i64* %num_done, align 8, !tbaa !14
  br label %if.end

if.then.i.i.i148:                                 ; preds = %lpad.i123
  %181 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i109, align 8, !tbaa !2
  %capacity.i.i.i.i.i146 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %181, i64 0, i32 0
  %182 = load i64, i64* %capacity.i.i.i.i.i146, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i147 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i151 unwind label %lpad.i.i153

call.i.i.i.i.i.noexc.i.i151:                      ; preds = %if.then.i.i.i148
  %183 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %181 to i8*
  %mul.i.i.i.i.i149 = shl i64 %182, 3
  %add.i.i.i.i.i150 = add i64 %mul.i.i.i.i.i149, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i147, i8* %183, i64 %add.i.i.i.i.i150)
          to label %.noexc.i.i152 unwind label %lpad.i.i153

.noexc.i.i152:                                    ; preds = %call.i.i.i.i.i.noexc.i.i151
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i109, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit154

lpad.i.i153:                                      ; preds = %call.i.i.i.i.i.noexc.i.i151, %if.then.i.i.i148
  %184 = landingpad { i8*, i32 }
          catch i8* null
  %185 = extractvalue { i8*, i32 } %184, 0
  call void @__clang_call_terminate(i8* %185) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit154: ; preds = %.noexc.i.i152, %lpad.i123
  store i8 0, i8* %small_n.i.i.i.i.i, align 2
  br label %ehcleanup

ehcleanup:                                        ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit154, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i.i
  %ehselector.slot.0 = phi i32 [ %175, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit154 ], [ %172, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i.i ]
  %exn.slot.0 = phi i8* [ %174, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit154 ], [ %171, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i.i ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %92) #16
  br label %ehcleanup78

if.end:                                           ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit141, %while.body
  %186 = phi i64 [ %.pre, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit141 ], [ %157, %while.body ]
  %num_next_rebuild.1 = phi i64 [ %mul, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit141 ], [ %num_next_rebuild.0675, %while.body ]
  %div26 = udiv i64 %186, 50
  %add27 = add nuw nsw i64 %div26, 1
  %sub = sub i64 %retval.0.i.i, %186
  %cmp.i = icmp ugt i64 %sub, %div26
  %187 = select i1 %cmp.i, i64 %add27, i64 %sub
  %cmp.i155 = icmp ult i64 %add, %187
  %.sroa.speculated = select i1 %cmp.i155, i64 %add, i64 %187
  store %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"** %104, align 8, !tbaa !13
  store i64* %num_remain, i64** %105, align 8, !tbaa !13
  store %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %remain, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"** %106, align 8, !tbaa !13
  store %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %v, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"** %107, align 8, !tbaa !13
  store i64* %num_done, i64** %108, align 8, !tbaa !13
  store %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963* %knn, %struct.k_nearest_neighbors.117.428.735.1042.1349.1656.1963** %109, align 8, !tbaa !13
  store %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"* %t, %"class.parlay::sequence.33.126.437.744.1051.1358.1665.1972"** %110, align 8, !tbaa !13
  store %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"** %111, align 8, !tbaa !13
  invoke fastcc void @"_ZN6parlay12parallel_forIZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEEES6_E3$_4EEvmmT_mb"(i64 %.sroa.speculated, %class.anon.52.136.447.754.1061.1368.1675.1982* nonnull byval(%class.anon.52.136.447.754.1061.1368.1675.1982) align 8 %agg.tmp)
          to label %invoke.cont37 unwind label %lpad36.loopexit.split-lp

invoke.cont37:                                    ; preds = %if.end
  %cmp1.i = icmp eq i64 %.sroa.speculated, 0
  br i1 %cmp1.i, label %invoke.cont39, label %pfor.cond.i

pfor.cond.i:                                      ; preds = %pfor.inc.i, %invoke.cont37
  %__begin.0.i = phi i64 [ %inc.i, %pfor.inc.i ], [ 0, %invoke.cont37 ]
  detach within %syncreg.i, label %_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEixEm.exit.i.i, label %pfor.inc.i unwind label %lpad36.loopexit

_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEixEm.exit.i.i: ; preds = %pfor.cond.i
  %bf.load.i.i.i.i.i.i158 = load i8, i8* %small_n.i.i.i.i28, align 2
  %cmp.i.i.i.i.i.i159 = icmp sgt i8 %bf.load.i.i.i.i.i.i158, -1
  %188 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i.i.i, align 8
  %data.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %188, i64 0, i32 1, i32 0
  %189 = bitcast [1 x i8]* %data.i.i.i.i.i.i.i.i to %struct.vertex.52.363.670.977.1284.1591.1898**
  %retval.0.i.i.i.i.i = select i1 %cmp.i.i.i.i.i.i159, %struct.vertex.52.363.670.977.1284.1591.1898** %112, %struct.vertex.52.363.670.977.1284.1591.1898** %189
  %arrayidx.i.i.i.i = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %retval.0.i.i.i.i.i, i64 %__begin.0.i
  %190 = load %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %arrayidx.i.i.i.i, align 8, !tbaa !13
  %bf.load.i.i.i.i14.i.i = load i8, i8* %small_n.i.i.i.i44, align 2
  %cmp.i.i.i.i15.i.i = icmp sgt i8 %bf.load.i.i.i.i14.i.i, -1
  %191 = load %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"*, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i500, align 8
  %data.i.i.i.i.i.i18.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965", %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %191, i64 0, i32 1, i32 0
  %192 = bitcast [1 x i8]* %data.i.i.i.i.i.i18.i.i to %struct.simplex.58.369.676.983.1290.1597.1904*
  %retval.0.i.i.i20.i.i = select i1 %cmp.i.i.i.i15.i.i, %struct.simplex.58.369.676.983.1290.1597.1904* %21, %struct.simplex.58.369.676.983.1290.1597.1904* %192
  %agg.tmp.sroa.0.0..sroa_idx.i.i = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i.i20.i.i, i64 %__begin.0.i, i32 0
  %agg.tmp.sroa.0.0.copyload.i.i = load %struct.triangle.53.364.671.978.1285.1592.1899*, %struct.triangle.53.364.671.978.1285.1592.1899** %agg.tmp.sroa.0.0..sroa_idx.i.i, align 8, !tbaa.struct !56
  %agg.tmp.sroa.2.0..sroa_idx1.i.i = getelementptr inbounds %struct.simplex.58.369.676.983.1290.1597.1904, %struct.simplex.58.369.676.983.1290.1597.1904* %retval.0.i.i.i20.i.i, i64 %__begin.0.i, i32 1
  %agg.tmp.sroa.2.0..sroa_cast.i.i = bitcast i32* %agg.tmp.sroa.2.0..sroa_idx1.i.i to i64*
  %agg.tmp.sroa.2.0.copyload.i.i = load i64, i64* %agg.tmp.sroa.2.0..sroa_cast.i.i, align 8, !tbaa.struct !56
  %bf.load.i.i.i.i23.i.i = load i8, i8* %small_n.i.i.i.i.i.i, align 2
  %cmp.i.i.i.i24.i.i = icmp sgt i8 %bf.load.i.i.i.i23.i.i, -1
  %193 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i26.i.i, align 8
  %data.i.i.i.i.i.i27.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %193, i64 0, i32 1, i32 0
  %194 = bitcast [1 x i8]* %data.i.i.i.i.i.i27.i.i to %struct.Qs.63.374.681.988.1295.1602.1909*
  %retval.0.i.i.i29.i.i = select i1 %cmp.i.i.i.i24.i.i, %struct.Qs.63.374.681.988.1295.1602.1909* %113, %struct.Qs.63.374.681.988.1295.1602.1909* %194
  %arrayidx.i.i30.i.i = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %retval.0.i.i.i29.i.i, i64 %__begin.0.i
  %call4.i.i162 = invoke zeroext i1 @_Z6insertP6vertexI7point2dIdEE7simplexIS1_EP2QsIS1_E(%struct.vertex.52.363.670.977.1284.1591.1898* %190, %struct.triangle.53.364.671.978.1285.1592.1899* %agg.tmp.sroa.0.0.copyload.i.i, i64 %agg.tmp.sroa.2.0.copyload.i.i, %struct.Qs.63.374.681.988.1295.1602.1909* nonnull %arrayidx.i.i30.i.i)
          to label %call4.i.i.noexc unwind label %lpad36161

call4.i.i.noexc:                                  ; preds = %_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEixEm.exit.i.i
  %bf.load.i.i.i.i6.i.i = load i8, i8* %small_n.i.i.i.i58, align 2
  %cmp.i.i.i.i7.i.i = icmp sgt i8 %bf.load.i.i.i.i6.i.i, -1
  %195 = load %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"*, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i.i9.i.i, align 8
  %196 = getelementptr inbounds %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029", %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %195, i64 0, i32 1, i32 0, i64 0
  %retval.0.i.i.i11.i.i = select i1 %cmp.i.i.i.i7.i.i, i8* %38, i8* %196
  %arrayidx.i.i12.i.i = getelementptr inbounds i8, i8* %retval.0.i.i.i11.i.i, i64 %__begin.0.i
  %frombool.i.i = zext i1 %call4.i.i162 to i8
  store i8 %frombool.i.i, i8* %arrayidx.i.i12.i.i, align 1, !tbaa !58
  reattach within %syncreg.i, label %pfor.inc.i

pfor.inc.i:                                       ; preds = %call4.i.i.noexc, %pfor.cond.i
  %inc.i = add nuw nsw i64 %__begin.0.i, 1
  %exitcond.i = icmp eq i64 %inc.i, %.sroa.speculated
  br i1 %exitcond.i, label %pfor.cond.cleanup.i, label %pfor.cond.i, !llvm.loop !59

pfor.cond.cleanup.i:                              ; preds = %pfor.inc.i
  sync within %syncreg.i, label %sync.continue.i

sync.continue.i:                                  ; preds = %pfor.cond.cleanup.i
  invoke void @llvm.sync.unwind(token %syncreg.i)
          to label %invoke.cont39 unwind label %lpad36.loopexit.split-lp

lpad36.unreachable:                               ; preds = %lpad36161
  unreachable

lpad36161:                                        ; preds = %_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEixEm.exit.i.i
  %197 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i, { i8*, i32 } %197)
          to label %lpad36.unreachable unwind label %lpad36.loopexit

invoke.cont39:                                    ; preds = %sync.continue.i, %invoke.cont37
  %bf.load.i.i.i.i165 = load i8, i8* %small_n.i.i.i.i28, align 2
  %cmp.i.i.i.i166 = icmp sgt i8 %bf.load.i.i.i.i165, -1
  %198 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i.i.i, align 8
  %data.i.i.i.i.i.i169 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %198, i64 0, i32 1, i32 0
  %199 = bitcast [1 x i8]* %data.i.i.i.i.i.i169 to %struct.vertex.52.363.670.977.1284.1591.1898**
  %.pn.i172 = select i1 %cmp.i.i.i.i166, %struct.vertex.52.363.670.977.1284.1591.1898** %112, %struct.vertex.52.363.670.977.1284.1591.1898** %199
  %add.ptr3.i174 = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i172, i64 %.sroa.speculated
  %200 = ptrtoint %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i172 to i64
  %201 = ptrtoint %struct.vertex.52.363.670.977.1284.1591.1898** %add.ptr3.i174 to i64
  %bf.load.i.i.i.i179 = load i8, i8* %small_n.i.i.i.i58, align 2
  %cmp.i.i.i.i180 = icmp sgt i8 %bf.load.i.i.i.i179, -1
  %202 = load %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"*, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i.i9.i.i, align 8
  %add.ptr.i = getelementptr inbounds %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029", %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %202, i64 0, i32 1, i32 0, i64 0
  %add.ptr11.i = select i1 %cmp.i.i.i.i180, i8* %38, i8* %add.ptr.i
  %add.ptr3.i183 = getelementptr inbounds i8, i8* %add.ptr11.i, i64 %.sroa.speculated
  %203 = ptrtoint i8* %add.ptr11.i to i64
  %204 = ptrtoint i8* %add.ptr3.i183 to i64
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %114) #16, !noalias !60
  store i64 %200, i64* %115, align 8, !noalias !60
  store i64 %201, i64* %117, align 8, !noalias !60
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %118) #16, !noalias !60
  store i64 %203, i64* %119, align 8, !noalias !60
  store i64 %204, i64* %121, align 8, !noalias !60
  invoke void @_ZN6parlay8internal4packINS_5sliceIPP6vertexI7point2dIdEES8_EENS2_IPbSA_EEEENS_8sequenceINT_10value_typeENS_9allocatorISE_EEEERKSD_RKT0_j(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* nonnull sret %agg.tmp40, %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* nonnull dereferenceable(16) %ref.tmp.i186, %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"* nonnull dereferenceable(16) %ref.tmp1.i, i32 0)
          to label %invoke.cont51 unwind label %lpad46

invoke.cont51:                                    ; preds = %invoke.cont39
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %118) #16, !noalias !60
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %114) #16, !noalias !60
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %122)
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 1 dereferenceable(15) %122, i8* nonnull align 8 dereferenceable(15) %18, i64 15, i1 false) #16
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(15) %18, i8* nonnull align 8 dereferenceable(15) %123, i64 15, i1 false) #16
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(15) %123, i8* nonnull align 1 dereferenceable(15) %122, i64 15, i1 false) #16
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %122)
  %bf.load.i.i.i.i189 = load i8, i8* %flag.i.i.i.i188, align 2
  %cmp.i.i.i.i190 = icmp sgt i8 %bf.load.i.i.i.i189, -1
  br i1 %cmp.i.i.i.i190, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit200, label %if.then.i.i.i194

if.then.i.i.i194:                                 ; preds = %invoke.cont51
  %205 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i191, align 8, !tbaa !2
  %capacity.i.i.i.i.i192 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %205, i64 0, i32 0
  %206 = load i64, i64* %capacity.i.i.i.i.i192, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i193 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i197 unwind label %lpad.i.i199

call.i.i.i.i.i.noexc.i.i197:                      ; preds = %if.then.i.i.i194
  %207 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %205 to i8*
  %mul.i.i.i.i.i195 = shl i64 %206, 3
  %add.i.i.i.i.i196 = add i64 %mul.i.i.i.i.i195, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i193, i8* %207, i64 %add.i.i.i.i.i196)
          to label %.noexc.i.i198 unwind label %lpad.i.i199

.noexc.i.i198:                                    ; preds = %call.i.i.i.i.i.noexc.i.i197
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i191, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit200

lpad.i.i199:                                      ; preds = %call.i.i.i.i.i.noexc.i.i197, %if.then.i.i.i194
  %208 = landingpad { i8*, i32 }
          catch i8* null
  %209 = extractvalue { i8*, i32 } %208, 0
  call void @__clang_call_terminate(i8* %209) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit200: ; preds = %.noexc.i.i198, %invoke.cont51
  store i8 0, i8* %flag.i.i.i.i188, align 2
  %bf.load.i.i.i202 = load i8, i8* %small_n.i.i.i.i43, align 2
  %cmp.i.i.i203 = icmp sgt i8 %bf.load.i.i.i202, -1
  %conv.i.i204 = zext i8 %bf.load.i.i.i202 to i64
  %bf.load.i1.i.i207 = load i48, i48* %124, align 8
  %bf.cast.i.i.i208 = zext i48 %bf.load.i1.i.i207 to i64
  %retval.0.i.i210 = select i1 %cmp.i.i.i203, i64 %conv.i.i204, i64 %bf.cast.i.i.i208
  store i64 %retval.0.i.i210, i64* %num_remain, align 8, !tbaa !14
  %sub58 = sub nsw i64 %.sroa.speculated, %retval.0.i.i210
  call void @llvm.lifetime.start.p0i8(i64 24, i8* nonnull %125) #16
  store i64 0, i64* %first.i.i, align 8, !tbaa !63, !alias.scope !66
  store i64 %.sroa.speculated, i64* %last.i.i, align 8, !tbaa !69, !alias.scope !66
  store i64 %126, i64* %127, align 8, !tbaa !13, !alias.scope !66
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %128) #16
  %bf.load.i.i.i.i213 = load i8, i8* %small_n.i.i.i.i28, align 2
  %cmp.i.i.i.i214 = icmp sgt i8 %bf.load.i.i.i.i213, -1
  %210 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i.i.i, align 8
  %data.i.i.i.i.i.i217 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %210, i64 0, i32 1, i32 0
  %211 = bitcast [1 x i8]* %data.i.i.i.i.i.i217 to %struct.vertex.52.363.670.977.1284.1591.1898**
  %.pn.i220 = select i1 %cmp.i.i.i.i214, %struct.vertex.52.363.670.977.1284.1591.1898** %112, %struct.vertex.52.363.670.977.1284.1591.1898** %211
  %add.ptr3.i222 = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i220, i64 %.sroa.speculated
  store %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i220, %struct.vertex.52.363.670.977.1284.1591.1898*** %129, align 8
  store %struct.vertex.52.363.670.977.1284.1591.1898** %add.ptr3.i222, %struct.vertex.52.363.670.977.1284.1591.1898*** %130, align 8
  %212 = load i64, i64* %num_done, align 8, !tbaa !14
  %add67 = add i64 %212, %sub58
  %bf.load.i.i.i.i227 = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i228 = icmp sgt i8 %bf.load.i.i.i.i227, -1
  %213 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i.i100, align 8
  %data.i.i.i.i.i.i231 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %213, i64 0, i32 1, i32 0
  %214 = bitcast [1 x i8]* %data.i.i.i.i.i.i231 to %struct.vertex.52.363.670.977.1284.1591.1898**
  %.pn.i234 = select i1 %cmp.i.i.i.i228, %struct.vertex.52.363.670.977.1284.1591.1898** %93, %struct.vertex.52.363.670.977.1284.1591.1898** %214
  %add.ptr12.i = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i234, i64 %212
  %add.ptr3.i236 = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i234, i64 %add67
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %131)
  store %struct.vertex.52.363.670.977.1284.1591.1898** %add.ptr12.i, %struct.vertex.52.363.670.977.1284.1591.1898*** %132, align 8
  store %struct.vertex.52.363.670.977.1284.1591.1898** %add.ptr3.i236, %struct.vertex.52.363.670.977.1284.1591.1898*** %133, align 8
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %134) #16
  br i1 %cmp1.i, label %if.then.i.thread, label %_ZN6parlay8internal10num_blocksEmm.exit.i

if.then.i.thread:                                 ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit200
  store i64 0, i64* %l.i, align 8, !tbaa !14
  br label %invoke.cont70

_ZN6parlay8internal10num_blocksEmm.exit.i:        ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit200
  %sub.i.i = add nsw i64 %.sroa.speculated, -1
  %div.i.i = lshr i64 %sub.i.i, 10
  %add.i.i = add nuw nsw i64 %div.i.i, 1
  store i64 %add.i.i, i64* %l.i, align 8, !tbaa !14
  %cmp.i241 = icmp eq i64 %div.i.i, 0
  br i1 %cmp.i241, label %for.body.i.i, label %if.end.i

for.body.i.i:                                     ; preds = %for.inc.i.i.for.body.i.i_crit_edge, %_ZN6parlay8internal10num_blocksEmm.exit.i
  %f.idx.val.i.i.i.i = phi %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* [ %f.idx.val.i.i.i.i.pre, %for.inc.i.i.for.body.i.i_crit_edge ], [ %flags, %_ZN6parlay8internal10num_blocksEmm.exit.i ]
  %i.03.i.i = phi i64 [ %inc4.i.i, %for.inc.i.i.for.body.i.i_crit_edge ], [ 0, %_ZN6parlay8internal10num_blocksEmm.exit.i ]
  %k.02.i.i = phi i64 [ %k.1.i.i, %for.inc.i.i.for.body.i.i_crit_edge ], [ 0, %_ZN6parlay8internal10num_blocksEmm.exit.i ]
  %flag.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %f.idx.val.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i.i.i.i.i = load i8, i8* %flag.i.i.i.i.i.i.i.i.i, align 1
  %cmp.i.i.i.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i, label %if.else.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i:                          ; preds = %for.body.i.i
  %215 = bitcast %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %f.idx.val.i.i.i.i to i8*
  br label %"_ZNK6parlay5sliceINS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_6E8iteratorESD_EixEm.exit.i.i"

if.else.i.i.i.i.i.i.i.i:                          ; preds = %for.body.i.i
  %buffer.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %f.idx.val.i.i.i.i, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %216 = load %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"*, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i.i.i.i.i.i.i, align 1, !tbaa !29
  %217 = getelementptr inbounds %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029", %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %216, i64 0, i32 1, i32 0, i64 0
  br label %"_ZNK6parlay5sliceINS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_6E8iteratorESD_EixEm.exit.i.i"

"_ZNK6parlay5sliceINS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_6E8iteratorESD_EixEm.exit.i.i": ; preds = %if.else.i.i.i.i.i.i.i.i, %if.then.i.i.i.i.i.i.i.i
  %retval.0.i.i.i.i.i.i.i.i = phi i8* [ %215, %if.then.i.i.i.i.i.i.i.i ], [ %217, %if.else.i.i.i.i.i.i.i.i ]
  %arrayidx.i.i.i.i.i.i.i = getelementptr inbounds i8, i8* %retval.0.i.i.i.i.i.i.i.i, i64 %i.03.i.i
  %218 = load i8, i8* %arrayidx.i.i.i.i.i.i.i, align 1, !tbaa !58, !range !70
  %tobool.i.i.i.i.i = icmp eq i8 %218, 0
  br i1 %tobool.i.i.i.i.i, label %if.then.i.i245, label %for.inc.i.i

if.then.i.i245:                                   ; preds = %"_ZNK6parlay5sliceINS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_6E8iteratorESD_EixEm.exit.i.i"
  %arrayidx.i8.i.i = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %add.ptr12.i, i64 %k.02.i.i
  %219 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %arrayidx.i8.i.i to i64*
  %arrayidx.i.i.i = getelementptr inbounds %struct.vertex.52.363.670.977.1284.1591.1898*, %struct.vertex.52.363.670.977.1284.1591.1898** %.pn.i220, i64 %i.03.i.i
  %220 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %arrayidx.i.i.i to i64*
  %inc.i.i = add i64 %k.02.i.i, 1
  %221 = load i64, i64* %220, align 8, !tbaa !13
  store i64 %221, i64* %219, align 8, !tbaa !13
  br label %for.inc.i.i

for.inc.i.i:                                      ; preds = %if.then.i.i245, %"_ZNK6parlay5sliceINS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_6E8iteratorESD_EixEm.exit.i.i"
  %k.1.i.i = phi i64 [ %inc.i.i, %if.then.i.i245 ], [ %k.02.i.i, %"_ZNK6parlay5sliceINS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_6E8iteratorESD_EixEm.exit.i.i" ]
  %inc4.i.i = add nuw nsw i64 %i.03.i.i, 1
  %cmp.i21.i = icmp ult i64 %inc4.i.i, %.sroa.speculated
  br i1 %cmp.i21.i, label %for.inc.i.i.for.body.i.i_crit_edge, label %invoke.cont70

for.inc.i.i.for.body.i.i_crit_edge:               ; preds = %for.inc.i.i
  %f.idx.val.i.i.i.i.pre = load %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"*, %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"** %f.idx.i.i.i.i, align 8, !tbaa !71
  br label %for.body.i.i

if.end.i:                                         ; preds = %_ZN6parlay8internal10num_blocksEmm.exit.i
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %135) #16
  store i8 0, i8* %small_n.i.i.i.i.i246, align 2
  invoke void @_ZN6parlay8sequenceImNS_9allocatorImEEE18initialize_defaultEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* nonnull %Sums.i, i64 %add.i.i)
          to label %invoke.cont9.i unwind label %lpad.i.i249

lpad.i.i249:                                      ; preds = %if.end.i
  %222 = landingpad { i8*, i32 }
          cleanup
  %bf.load.i.i.i.i.i.i247 = load i8, i8* %small_n.i.i.i.i.i246, align 2
  %cmp.i.i.i.i.i.i248 = icmp sgt i8 %bf.load.i.i.i.i.i.i247, -1
  br i1 %cmp.i.i.i.i.i.i248, label %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i.i, label %if.then.i.i.i.i.i253

if.then.i.i.i.i.i253:                             ; preds = %lpad.i.i249
  %223 = load %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"*, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8, !tbaa !72
  %capacity.i.i.i.i.i.i.i251 = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920", %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %223, i64 0, i32 0
  %224 = load i64, i64* %capacity.i.i.i.i.i.i.i251, align 8, !tbaa !74
  %call.i.i.i.i.i1.i.i.i.i252 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i.i256 unwind label %lpad.i.i.i.i258

call.i.i.i.i.i.noexc.i.i.i.i256:                  ; preds = %if.then.i.i.i.i.i253
  %225 = bitcast %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %223 to i8*
  %mul.i.i.i.i.i.i.i254 = shl i64 %224, 3
  %add.i.i.i.i.i.i.i255 = add i64 %mul.i.i.i.i.i.i.i254, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i.i252, i8* %225, i64 %add.i.i.i.i.i.i.i255)
          to label %.noexc.i.i.i.i257 unwind label %lpad.i.i.i.i258

.noexc.i.i.i.i257:                                ; preds = %call.i.i.i.i.i.noexc.i.i.i.i256
  store %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* null, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8, !tbaa !72
  br label %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i.i

lpad.i.i.i.i258:                                  ; preds = %call.i.i.i.i.i.noexc.i.i.i.i256, %if.then.i.i.i.i.i253
  %226 = landingpad { i8*, i32 }
          catch i8* null
  %227 = extractvalue { i8*, i32 } %226, 0
  call void @__clang_call_terminate(i8* %227) #17
  unreachable

_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i.i: ; preds = %.noexc.i.i.i.i257, %lpad.i.i249
  store i8 0, i8* %small_n.i.i.i.i.i246, align 2
  br label %ehcleanup75

invoke.cont9.i:                                   ; preds = %if.end.i
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %136) #16
  store %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"** %137, align 8, !tbaa !13
  store %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags, %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"** %138, align 8, !tbaa !13
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %139)
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %140)
  store i64 %.sroa.speculated, i64* %n.addr.i.i, align 8, !tbaa !14
  store i64 1024, i64* %block_size.addr.i.i, align 8, !tbaa !14
  call fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_8pack_outINS_5sliceIPP6vertexI7point2dIdEESA_EENS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIS9_NS_9allocatorIS9_EEEES9_E3$_6EESB_EEmRKT_RKT0_T1_jEUlmmmE_EEvmmSL_jEUlmE_EEvmmSJ_mb"(i64 0, i64 %add.i.i, i64* nonnull %block_size.addr.i.i, i64* nonnull %n.addr.i.i, %class.anon.264.286.593.900.1207.1514.1821.2128* nonnull %ref.tmp6.i) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %139)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %140)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %136) #16
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %141) #16
  %bf.load.i.i.i.i.i22.i = load i8, i8* %small_n.i.i.i.i.i246, align 2
  %cmp.i.i.i.i.i23.i = icmp sgt i8 %bf.load.i.i.i.i.i22.i, -1
  %228 = load %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"*, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8
  %data.i.i.i.i.i.i.i.i260 = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920", %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %228, i64 0, i32 1, i32 0
  %229 = bitcast [1 x i8]* %data.i.i.i.i.i.i.i.i260 to i64*
  %retval.0.i.i.i.i.i261 = select i1 %cmp.i.i.i.i.i23.i, i64* %142, i64* %229
  %conv.i.i.i.i.i = zext i8 %bf.load.i.i.i.i.i22.i to i64
  %bf.load.i1.i.i.i.i.i = load i48, i48* %143, align 8
  %bf.cast.i.i.i.i.i.i = zext i48 %bf.load.i1.i.i.i.i.i to i64
  %retval.0.i6.i.i.i.i = select i1 %cmp.i.i.i.i.i23.i, i64 %conv.i.i.i.i.i, i64 %bf.cast.i.i.i.i.i.i
  %add.ptr.i.i.i.i = getelementptr inbounds i64, i64* %retval.0.i.i.i.i.i261, i64 %retval.0.i6.i.i.i.i
  call void @llvm.lifetime.start.p0i8(i64 16, i8* nonnull %144)
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %145)
  store i64* %retval.0.i.i.i.i.i261, i64** %146, align 8
  store i64* %add.ptr.i.i.i.i, i64** %147, align 8
  store i64 0, i64* %coerce.dive.i.i, align 8
  %call.i24.i = invoke i64 @_ZN6parlay8internal5scan_INS_5sliceIPmS3_EES4_NS_4addmImEEEENT_10value_typeERKS7_T0_RKT1_jb(%"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"* nonnull dereferenceable(16) %In.i.i, i64* nonnull %retval.0.i.i.i.i.i261, i64* nonnull %add.ptr.i.i.i.i, %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* nonnull dereferenceable(8) %m.i.i, i32 0, i1 zeroext false)
          to label %invoke.cont17.i unwind label %ehcleanup18.i

invoke.cont17.i:                                  ; preds = %invoke.cont9.i
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %144)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %145)
  store i64 %call.i24.i, i64* %m.i, align 8, !tbaa !14
  call void @llvm.lifetime.start.p0i8(i64 48, i8* nonnull %148) #16
  store %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %ref.tmp62, %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"** %149, align 8, !tbaa !13
  store %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"* %not_flags, %"class.parlay::delayed_sequence.285.592.899.1206.1513.1820.2127"** %150, align 8, !tbaa !13
  store %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* %Out.i, %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"** %151, align 8, !tbaa !13
  store %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* %Sums.i, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"** %152, align 8, !tbaa !13
  store i64* %l.i, i64** %153, align 8, !tbaa !13
  store i64* %m.i, i64** %154, align 8, !tbaa !13
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %155)
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %156)
  store i64 %.sroa.speculated, i64* %n.addr.i25.i, align 8, !tbaa !14
  store i64 1024, i64* %block_size.addr.i26.i, align 8, !tbaa !14
  call fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_8pack_outINS_5sliceIPP6vertexI7point2dIdEESA_EENS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIS9_NS_9allocatorIS9_EEEES9_E3$_6EESB_EEmRKT_RKT0_T1_jEUlmmmE0_EEvmmSL_jEUlmE_EEvmmSJ_mb"(i64 0, i64 %add.i.i, i64* nonnull %block_size.addr.i26.i, i64* nonnull %n.addr.i25.i, %class.anon.265.287.594.901.1208.1515.1822.2129* nonnull %ref.tmp15.i) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %155)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %156)
  call void @llvm.lifetime.end.p0i8(i64 48, i8* nonnull %148) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %141) #16
  %bf.load.i.i.i.i6.i = load i8, i8* %small_n.i.i.i.i.i246, align 2
  %cmp.i.i.i.i7.i = icmp sgt i8 %bf.load.i.i.i.i6.i, -1
  br i1 %cmp.i.i.i.i7.i, label %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit17.i, label %if.then.i.i.i11.i

if.then.i.i.i11.i:                                ; preds = %invoke.cont17.i
  %230 = load %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"*, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8, !tbaa !72
  %capacity.i.i.i.i.i9.i = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920", %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %230, i64 0, i32 0
  %231 = load i64, i64* %capacity.i.i.i.i.i9.i, align 8, !tbaa !74
  %call.i.i.i.i.i1.i.i10.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i14.i unwind label %lpad.i.i16.i

call.i.i.i.i.i.noexc.i.i14.i:                     ; preds = %if.then.i.i.i11.i
  %232 = bitcast %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %230 to i8*
  %mul.i.i.i.i.i12.i = shl i64 %231, 3
  %add.i.i.i.i.i13.i = add i64 %mul.i.i.i.i.i12.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i10.i, i8* %232, i64 %add.i.i.i.i.i13.i)
          to label %.noexc.i.i15.i unwind label %lpad.i.i16.i

.noexc.i.i15.i:                                   ; preds = %call.i.i.i.i.i.noexc.i.i14.i
  store %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* null, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8, !tbaa !72
  br label %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit17.i

lpad.i.i16.i:                                     ; preds = %call.i.i.i.i.i.noexc.i.i14.i, %if.then.i.i.i11.i
  %233 = landingpad { i8*, i32 }
          catch i8* null
  %234 = extractvalue { i8*, i32 } %233, 0
  call void @__clang_call_terminate(i8* %234) #17
  unreachable

_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit17.i: ; preds = %.noexc.i.i15.i, %invoke.cont17.i
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %135) #16
  br label %invoke.cont70

ehcleanup18.i:                                    ; preds = %invoke.cont9.i
  %235 = landingpad { i8*, i32 }
          cleanup
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %141) #16
  %bf.load.i.i.i.i.i262 = load i8, i8* %small_n.i.i.i.i.i246, align 2
  %cmp.i.i.i.i.i263 = icmp sgt i8 %bf.load.i.i.i.i.i262, -1
  br i1 %cmp.i.i.i.i.i263, label %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i, label %if.then.i.i.i.i267

if.then.i.i.i.i267:                               ; preds = %ehcleanup18.i
  %236 = load %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"*, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8, !tbaa !72
  %capacity.i.i.i.i.i.i265 = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920", %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %236, i64 0, i32 0
  %237 = load i64, i64* %capacity.i.i.i.i.i.i265, align 8, !tbaa !74
  %call.i.i.i.i.i1.i.i.i266 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i.i270 unwind label %lpad.i.i.i272

call.i.i.i.i.i.noexc.i.i.i270:                    ; preds = %if.then.i.i.i.i267
  %238 = bitcast %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* %236 to i8*
  %mul.i.i.i.i.i.i268 = shl i64 %237, 3
  %add.i.i.i.i.i.i269 = add i64 %mul.i.i.i.i.i.i268, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i.i266, i8* %238, i64 %add.i.i.i.i.i.i269)
          to label %.noexc.i.i.i271 unwind label %lpad.i.i.i272

.noexc.i.i.i271:                                  ; preds = %call.i.i.i.i.i.noexc.i.i.i270
  store %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"* null, %"struct.parlay::_sequence_base<unsigned long, parlay::allocator<unsigned long> >::_sequence_impl::capacitated_buffer::header.74.385.692.999.1306.1613.1920"** %buffer.i.i.i.i.i.i.i259, align 8, !tbaa !72
  br label %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i

lpad.i.i.i272:                                    ; preds = %call.i.i.i.i.i.noexc.i.i.i270, %if.then.i.i.i.i267
  %239 = landingpad { i8*, i32 }
          catch i8* null
  %240 = extractvalue { i8*, i32 } %239, 0
  call void @__clang_call_terminate(i8* %240) #17
  unreachable

_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i: ; preds = %.noexc.i.i.i271, %ehcleanup18.i
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %135) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %134) #16
  br label %ehcleanup75

invoke.cont70:                                    ; preds = %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit17.i, %for.inc.i.i, %if.then.i.thread
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %134) #16
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %131)
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %128) #16
  %241 = load i64, i64* %num_done, align 8, !tbaa !14
  %add74 = add i64 %241, %sub58
  store i64 %add74, i64* %num_done, align 8, !tbaa !14
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %125) #16
  %cmp = icmp ult i64 %add74, %retval.0.i.i
  br i1 %cmp, label %while.body, label %while.end

lpad36.loopexit:                                  ; preds = %lpad36161, %pfor.cond.i
  %lpad.loopexit = landingpad { i8*, i32 }
          cleanup
  br label %lpad36

lpad36.loopexit.split-lp:                         ; preds = %sync.continue.i, %if.end
  %lpad.loopexit.split-lp = landingpad { i8*, i32 }
          cleanup
  br label %lpad36

lpad36:                                           ; preds = %lpad36.loopexit.split-lp, %lpad36.loopexit
  %lpad.phi = phi { i8*, i32 } [ %lpad.loopexit, %lpad36.loopexit ], [ %lpad.loopexit.split-lp, %lpad36.loopexit.split-lp ]
  %242 = extractvalue { i8*, i32 } %lpad.phi, 0
  %243 = extractvalue { i8*, i32 } %lpad.phi, 1
  br label %ehcleanup78

lpad46:                                           ; preds = %invoke.cont39
  %244 = landingpad { i8*, i32 }
          cleanup
  %245 = extractvalue { i8*, i32 } %244, 0
  %246 = extractvalue { i8*, i32 } %244, 1
  br label %ehcleanup78

ehcleanup75:                                      ; preds = %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i, %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i.i
  %eh.lpad-body273 = phi { i8*, i32 } [ %222, %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i.i ], [ %235, %_ZN6parlay14_sequence_baseImNS_9allocatorImEEED2Ev.exit.i ]
  %247 = extractvalue { i8*, i32 } %eh.lpad-body273, 0
  %248 = extractvalue { i8*, i32 } %eh.lpad-body273, 1
  call void @llvm.lifetime.end.p0i8(i64 16, i8* nonnull %128) #16
  call void @llvm.lifetime.end.p0i8(i64 24, i8* nonnull %125) #16
  br label %ehcleanup78

while.end:                                        ; preds = %invoke.cont70, %invoke.cont12
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %91) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %90) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %85) #16
  %bf.load.i.i.i.i289 = load i8, i8* %small_n.i.i.i.i80, align 2
  %cmp.i.i.i.i290 = icmp sgt i8 %bf.load.i.i.i.i289, -1
  br i1 %cmp.i.i.i.i290, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit300.tf, label %if.then.i.i.i294

if.then.i.i.i294:                                 ; preds = %while.end
  %buffer.i.i.i.i291 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %init, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %249 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i291, align 8, !tbaa !2
  %capacity.i.i.i.i.i292 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %249, i64 0, i32 0
  %250 = load i64, i64* %capacity.i.i.i.i.i292, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i293 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i297 unwind label %lpad.i.i299

call.i.i.i.i.i.noexc.i.i297:                      ; preds = %if.then.i.i.i294
  %251 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %249 to i8*
  %mul.i.i.i.i.i295 = shl i64 %250, 3
  %add.i.i.i.i.i296 = add i64 %mul.i.i.i.i.i295, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i293, i8* %251, i64 %add.i.i.i.i.i296)
          to label %.noexc.i.i298 unwind label %lpad.i.i299

.noexc.i.i298:                                    ; preds = %call.i.i.i.i.i.noexc.i.i297
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i291, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit300.tf

lpad.i.i299:                                      ; preds = %call.i.i.i.i.i.noexc.i.i297, %if.then.i.i.i294
  %252 = landingpad { i8*, i32 }
          catch i8* null
  %253 = extractvalue { i8*, i32 } %252, 0
  call void @__clang_call_terminate(i8* %253) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit300.tf: ; preds = %.noexc.i.i298, %while.end
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %83) #16
  %bf.load.i.i = load i8, i8* %small_n.i.i.i.i.i.i, align 2
  %cmp.i.i302 = icmp sgt i8 %bf.load.i.i, -1
  br i1 %cmp.i.i302, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i: ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit300.tf
  %bf.load.i1.i.i.i = load i48, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i, align 8
  %bf.cast.i.i.i.i = zext i48 %bf.load.i1.i.i.i to i64
  %buffer.i.i.i.i.i303 = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %254 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i303, align 8, !tbaa !40
  %data.i.i.i.i.i.i304 = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %254, i64 0, i32 1, i32 0
  %255 = bitcast [1 x i8]* %data.i.i.i.i.i.i304 to %struct.Qs.63.374.681.988.1295.1602.1909*
  %cmp1.i.i.i = icmp eq i48 %bf.load.i1.i.i.i, 0
  br i1 %cmp1.i.i.i, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i, label %pfor.cond.i.i.i.preheader

pfor.cond.i.i.i.preheader:                        ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i
  %256 = add nsw i64 %bf.cast.i.i.i.i, -1
  %xtraiter = and i64 %bf.cast.i.i.i.i, 2047
  %257 = icmp ult i64 %256, 2047
  br i1 %257, label %pfor.cond.cleanup.i.i.i.strpm-lcssa, label %pfor.cond.i.i.i.preheader.new

pfor.cond.i.i.i.preheader.new:                    ; preds = %pfor.cond.i.i.i.preheader
  %stripiter = lshr i64 %bf.cast.i.i.i.i, 11
  br label %pfor.cond.i.i.i.strpm.outer

pfor.cond.i.i.i.strpm.outer:                      ; preds = %pfor.inc.i.i.i.strpm.outer, %pfor.cond.i.i.i.preheader.new
  %niter = phi i64 [ 0, %pfor.cond.i.i.i.preheader.new ], [ %niter.nadd, %pfor.inc.i.i.i.strpm.outer ]
  detach within %syncreg19.i.i.i516, label %pfor.body.i.i.i.strpm.outer, label %pfor.inc.i.i.i.strpm.outer

pfor.body.i.i.i.strpm.outer:                      ; preds = %pfor.cond.i.i.i.strpm.outer
  %258 = shl i64 %niter, 11
  br label %pfor.cond.i.i.i

pfor.cond.i.i.i:                                  ; preds = %pfor.inc.i.i.i, %pfor.body.i.i.i.strpm.outer
  %__begin.0.i.i.i = phi i64 [ %inc.i.i.i, %pfor.inc.i.i.i ], [ %258, %pfor.body.i.i.i.strpm.outer ]
  %inneriter = phi i64 [ %inneriter.nsub, %pfor.inc.i.i.i ], [ 2048, %pfor.body.i.i.i.strpm.outer ]
  %_M_start.i.i.i.i.i.i.i.i.i.i.i = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %255, i64 %__begin.0.i.i.i, i32 1, i32 0, i32 0, i32 0, i32 0
  %259 = load %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904** %_M_start.i.i.i.i.i.i.i.i.i.i.i, align 8, !tbaa !42
  %tobool.i.i.i.i.i.i.i.i.i.i.i.i = icmp eq %struct.simplex.58.369.676.983.1290.1597.1904* %259, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i.i.i, label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i, label %if.then.i.i.i.i.i.i.i.i.i.i.i.i

if.then.i.i.i.i.i.i.i.i.i.i.i.i:                  ; preds = %pfor.cond.i.i.i
  %260 = bitcast %struct.simplex.58.369.676.983.1290.1597.1904* %259 to i8*
  call void @_ZdlPv(i8* nonnull %260) #16
  br label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i

_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i.i, %pfor.cond.i.i.i
  %_M_start.i.i1.i.i.i.i.i.i.i.i.i = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %255, i64 %__begin.0.i.i.i, i32 0, i32 0, i32 0, i32 0, i32 0
  %261 = load %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898*** %_M_start.i.i1.i.i.i.i.i.i.i.i.i, align 8, !tbaa !44
  %tobool.i.i.i2.i.i.i.i.i.i.i.i.i = icmp eq %struct.vertex.52.363.670.977.1284.1591.1898** %261, null
  br i1 %tobool.i.i.i2.i.i.i.i.i.i.i.i.i, label %pfor.inc.i.i.i, label %if.then.i.i.i3.i.i.i.i.i.i.i.i.i

if.then.i.i.i3.i.i.i.i.i.i.i.i.i:                 ; preds = %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i
  %262 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %261 to i8*
  call void @_ZdlPv(i8* nonnull %262) #16
  br label %pfor.inc.i.i.i

pfor.inc.i.i.i:                                   ; preds = %if.then.i.i.i3.i.i.i.i.i.i.i.i.i, %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i
  %inc.i.i.i = add nuw nsw i64 %__begin.0.i.i.i, 1
  %inneriter.nsub = add nsw i64 %inneriter, -1
  %inneriter.ncmp = icmp eq i64 %inneriter.nsub, 0
  br i1 %inneriter.ncmp, label %pfor.inc.i.i.i.reattach, label %pfor.cond.i.i.i, !llvm.loop !76

pfor.inc.i.i.i.reattach:                          ; preds = %pfor.inc.i.i.i
  reattach within %syncreg19.i.i.i516, label %pfor.inc.i.i.i.strpm.outer

pfor.inc.i.i.i.strpm.outer:                       ; preds = %pfor.inc.i.i.i.reattach, %pfor.cond.i.i.i.strpm.outer
  %niter.nadd = add nuw nsw i64 %niter, 1
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter
  br i1 %niter.ncmp, label %pfor.cond.cleanup.i.i.i.strpm-lcssa, label %pfor.cond.i.i.i.strpm.outer, !llvm.loop !77

pfor.cond.cleanup.i.i.i.strpm-lcssa:              ; preds = %pfor.inc.i.i.i.strpm.outer, %pfor.cond.i.i.i.preheader
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %pfor.cond.cleanup.i.i.i, label %pfor.cond.i.i.i.epil.preheader

pfor.cond.i.i.i.epil.preheader:                   ; preds = %pfor.cond.cleanup.i.i.i.strpm-lcssa
  %263 = and i64 %bf.cast.i.i.i.i, 281474976708608
  br label %pfor.cond.i.i.i.epil

pfor.cond.i.i.i.epil:                             ; preds = %pfor.inc.i.i.i.epil, %pfor.cond.i.i.i.epil.preheader
  %__begin.0.i.i.i.epil = phi i64 [ %inc.i.i.i.epil, %pfor.inc.i.i.i.epil ], [ %263, %pfor.cond.i.i.i.epil.preheader ]
  %epil.iter = phi i64 [ %epil.iter.sub, %pfor.inc.i.i.i.epil ], [ %xtraiter, %pfor.cond.i.i.i.epil.preheader ]
  %_M_start.i.i.i.i.i.i.i.i.i.i.i.epil = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %255, i64 %__begin.0.i.i.i.epil, i32 1, i32 0, i32 0, i32 0, i32 0
  %264 = load %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904** %_M_start.i.i.i.i.i.i.i.i.i.i.i.epil, align 8, !tbaa !42
  %tobool.i.i.i.i.i.i.i.i.i.i.i.i.epil = icmp eq %struct.simplex.58.369.676.983.1290.1597.1904* %264, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i.i.i.epil, label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i.epil, label %if.then.i.i.i.i.i.i.i.i.i.i.i.i.epil

if.then.i.i.i.i.i.i.i.i.i.i.i.i.epil:             ; preds = %pfor.cond.i.i.i.epil
  %265 = bitcast %struct.simplex.58.369.676.983.1290.1597.1904* %264 to i8*
  call void @_ZdlPv(i8* nonnull %265) #16
  br label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i.epil

_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i.epil: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i.i.epil, %pfor.cond.i.i.i.epil
  %_M_start.i.i1.i.i.i.i.i.i.i.i.i.epil = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %255, i64 %__begin.0.i.i.i.epil, i32 0, i32 0, i32 0, i32 0, i32 0
  %266 = load %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898*** %_M_start.i.i1.i.i.i.i.i.i.i.i.i.epil, align 8, !tbaa !44
  %tobool.i.i.i2.i.i.i.i.i.i.i.i.i.epil = icmp eq %struct.vertex.52.363.670.977.1284.1591.1898** %266, null
  br i1 %tobool.i.i.i2.i.i.i.i.i.i.i.i.i.epil, label %pfor.inc.i.i.i.epil, label %if.then.i.i.i3.i.i.i.i.i.i.i.i.i.epil

if.then.i.i.i3.i.i.i.i.i.i.i.i.i.epil:            ; preds = %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i.epil
  %267 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %266 to i8*
  call void @_ZdlPv(i8* nonnull %267) #16
  br label %pfor.inc.i.i.i.epil

pfor.inc.i.i.i.epil:                              ; preds = %if.then.i.i.i3.i.i.i.i.i.i.i.i.i.epil, %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i.epil
  %inc.i.i.i.epil = add nuw nsw i64 %__begin.0.i.i.i.epil, 1
  %epil.iter.sub = add nsw i64 %epil.iter, -1
  %epil.iter.cmp = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %pfor.cond.cleanup.i.i.i, label %pfor.cond.i.i.i.epil, !llvm.loop !78

pfor.cond.cleanup.i.i.i:                          ; preds = %pfor.inc.i.i.i.epil, %pfor.cond.cleanup.i.i.i.strpm-lcssa
  sync within %syncreg19.i.i.i516, label %sync.continue.i.i.i

sync.continue.i.i.i:                              ; preds = %pfor.cond.cleanup.i.i.i
  invoke void @llvm.sync.unwind(token %syncreg19.i.i.i516)
          to label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i unwind label %lpad.i.i301307

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i: ; preds = %sync.continue.i.i.i, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i
  %268 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i303, align 8, !tbaa !40
  %capacity.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %268, i64 0, i32 0
  %269 = load i64, i64* %capacity.i.i.i, align 8, !tbaa !38
  %call.i.i.i.i.i310 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc unwind label %lpad.i.i301307

call.i.i.i.i.i.noexc:                             ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i
  %270 = bitcast %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %268 to i8*
  %mul.i.i.i = mul i64 %269, 48
  %add.i.i.i305 = or i64 %mul.i.i.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i310, i8* %270, i64 %add.i.i.i305)
          to label %.noexc311 unwind label %lpad.i.i301307

.noexc311:                                        ; preds = %call.i.i.i.i.i.noexc
  store %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* null, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i303, align 8, !tbaa !40
  br label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit

lpad.i.i301307:                                   ; preds = %call.i.i.i.i.i.noexc, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i, %sync.continue.i.i.i
  %271 = landingpad { i8*, i32 }
          catch i8* null
  %272 = extractvalue { i8*, i32 } %271, 0
  call void @__clang_call_terminate(i8* %272) #17
  unreachable

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit: ; preds = %.noexc311, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit300.tf
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %47) #16
  %bf.load.i.i.i.i313 = load i8, i8* %small_n.i.i.i.i58, align 2
  %cmp.i.i.i.i314 = icmp sgt i8 %bf.load.i.i.i.i313, -1
  br i1 %cmp.i.i.i.i314, label %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit, label %if.then.i.i.i318

if.then.i.i.i318:                                 ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit
  %buffer.i.i.i.i315 = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %273 = load %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"*, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i315, align 8, !tbaa !29
  %capacity.i.i.i.i.i316 = getelementptr inbounds %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029", %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %273, i64 0, i32 0
  %274 = load i64, i64* %capacity.i.i.i.i.i316, align 8, !tbaa !31
  %call.i.i.i.i.i1.i.i317 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i320 unwind label %lpad.i.i322

call.i.i.i.i.i.noexc.i.i320:                      ; preds = %if.then.i.i.i318
  %275 = bitcast %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %273 to i8*
  %add.i.i.i.i.i319 = add i64 %274, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i317, i8* %275, i64 %add.i.i.i.i.i319)
          to label %.noexc.i.i321 unwind label %lpad.i.i322

.noexc.i.i321:                                    ; preds = %call.i.i.i.i.i.noexc.i.i320
  store %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* null, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i315, align 8, !tbaa !29
  br label %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit

lpad.i.i322:                                      ; preds = %call.i.i.i.i.i.noexc.i.i320, %if.then.i.i.i318
  %276 = landingpad { i8*, i32 }
          catch i8* null
  %277 = extractvalue { i8*, i32 } %276, 0
  call void @__clang_call_terminate(i8* %277) #17
  unreachable

_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit: ; preds = %.noexc.i.i321, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %38) #16
  %bf.load.i.i.i.i324 = load i8, i8* %small_n.i.i.i.i44, align 2
  %cmp.i.i.i.i325 = icmp sgt i8 %bf.load.i.i.i.i324, -1
  br i1 %cmp.i.i.i.i325, label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit, label %if.then.i.i.i329

if.then.i.i.i329:                                 ; preds = %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit
  %278 = load %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"*, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i500, align 8, !tbaa !27
  %capacity.i.i.i.i.i327 = getelementptr inbounds %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965", %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %278, i64 0, i32 0
  %279 = load i64, i64* %capacity.i.i.i.i.i327, align 8, !tbaa !10
  %call.i.i.i.i.i1.i.i328 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i332 unwind label %lpad.i.i334

call.i.i.i.i.i.noexc.i.i332:                      ; preds = %if.then.i.i.i329
  %280 = bitcast %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %278 to i8*
  %mul.i.i.i.i.i330 = shl i64 %279, 4
  %add.i.i.i.i.i331 = or i64 %mul.i.i.i.i.i330, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i328, i8* %280, i64 %add.i.i.i.i.i331)
          to label %.noexc.i.i333 unwind label %lpad.i.i334

.noexc.i.i333:                                    ; preds = %call.i.i.i.i.i.noexc.i.i332
  store %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* null, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i500, align 8, !tbaa !27
  br label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit

lpad.i.i334:                                      ; preds = %call.i.i.i.i.i.noexc.i.i332, %if.then.i.i.i329
  %281 = landingpad { i8*, i32 }
          catch i8* null
  %282 = extractvalue { i8*, i32 } %281, 0
  call void @__clang_call_terminate(i8* %282) #17
  unreachable

_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit: ; preds = %.noexc.i.i333, %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %19) #16
  %bf.load.i.i.i.i336 = load i8, i8* %small_n.i.i.i.i43, align 2
  %cmp.i.i.i.i337 = icmp sgt i8 %bf.load.i.i.i.i336, -1
  br i1 %cmp.i.i.i.i337, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit347, label %if.then.i.i.i341

if.then.i.i.i341:                                 ; preds = %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit
  %buffer.i.i.i.i338 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %remain, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %283 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i338, align 8, !tbaa !2
  %capacity.i.i.i.i.i339 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %283, i64 0, i32 0
  %284 = load i64, i64* %capacity.i.i.i.i.i339, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i340 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i344 unwind label %lpad.i.i346

call.i.i.i.i.i.noexc.i.i344:                      ; preds = %if.then.i.i.i341
  %285 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %283 to i8*
  %mul.i.i.i.i.i342 = shl i64 %284, 3
  %add.i.i.i.i.i343 = add i64 %mul.i.i.i.i.i342, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i340, i8* %285, i64 %add.i.i.i.i.i343)
          to label %.noexc.i.i345 unwind label %lpad.i.i346

.noexc.i.i345:                                    ; preds = %call.i.i.i.i.i.noexc.i.i344
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i338, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit347

lpad.i.i346:                                      ; preds = %call.i.i.i.i.i.noexc.i.i344, %if.then.i.i.i341
  %286 = landingpad { i8*, i32 }
          catch i8* null
  %287 = extractvalue { i8*, i32 } %286, 0
  call void @__clang_call_terminate(i8* %287) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit347: ; preds = %.noexc.i.i345, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %18) #16
  %bf.load.i.i.i.i349 = load i8, i8* %small_n.i.i.i.i28, align 2
  %cmp.i.i.i.i350 = icmp sgt i8 %bf.load.i.i.i.i349, -1
  br i1 %cmp.i.i.i.i350, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit360, label %if.then.i.i.i354

if.then.i.i.i354:                                 ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit347
  %buffer.i.i.i.i351 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %288 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i351, align 8, !tbaa !2
  %capacity.i.i.i.i.i352 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %288, i64 0, i32 0
  %289 = load i64, i64* %capacity.i.i.i.i.i352, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i353 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i357 unwind label %lpad.i.i359

call.i.i.i.i.i.noexc.i.i357:                      ; preds = %if.then.i.i.i354
  %290 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %288 to i8*
  %mul.i.i.i.i.i355 = shl i64 %289, 3
  %add.i.i.i.i.i356 = add i64 %mul.i.i.i.i.i355, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i353, i8* %290, i64 %add.i.i.i.i.i356)
          to label %.noexc.i.i358 unwind label %lpad.i.i359

.noexc.i.i358:                                    ; preds = %call.i.i.i.i.i.noexc.i.i357
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i351, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit360

lpad.i.i359:                                      ; preds = %call.i.i.i.i.i.noexc.i.i357, %if.then.i.i.i354
  %291 = landingpad { i8*, i32 }
          catch i8* null
  %292 = extractvalue { i8*, i32 } %291, 0
  call void @__clang_call_terminate(i8* %292) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit360: ; preds = %.noexc.i.i358, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit347
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %9) #16
  %bf.load.i.i.i.i362 = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i363 = icmp sgt i8 %bf.load.i.i.i.i362, -1
  br i1 %cmp.i.i.i.i363, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit373, label %if.then.i.i.i367

if.then.i.i.i367:                                 ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit360
  %buffer.i.i.i.i364 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %293 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i364, align 8, !tbaa !2
  %capacity.i.i.i.i.i365 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %293, i64 0, i32 0
  %294 = load i64, i64* %capacity.i.i.i.i.i365, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i366 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i370 unwind label %lpad.i.i372

call.i.i.i.i.i.noexc.i.i370:                      ; preds = %if.then.i.i.i367
  %295 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %293 to i8*
  %mul.i.i.i.i.i368 = shl i64 %294, 3
  %add.i.i.i.i.i369 = add i64 %mul.i.i.i.i.i368, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i366, i8* %295, i64 %add.i.i.i.i.i369)
          to label %.noexc.i.i371 unwind label %lpad.i.i372

.noexc.i.i371:                                    ; preds = %call.i.i.i.i.i.noexc.i.i370
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i364, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit373

lpad.i.i372:                                      ; preds = %call.i.i.i.i.i.noexc.i.i370, %if.then.i.i.i367
  %296 = landingpad { i8*, i32 }
          catch i8* null
  %297 = extractvalue { i8*, i32 } %296, 0
  call void @__clang_call_terminate(i8* %297) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit373: ; preds = %.noexc.i.i371, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit360
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %2) #16
  ret void

ehcleanup78:                                      ; preds = %ehcleanup75, %lpad46, %lpad36, %ehcleanup
  %ehselector.slot.5 = phi i32 [ %ehselector.slot.0, %ehcleanup ], [ %248, %ehcleanup75 ], [ %243, %lpad36 ], [ %246, %lpad46 ]
  %exn.slot.5 = phi i8* [ %exn.slot.0, %ehcleanup ], [ %247, %ehcleanup75 ], [ %242, %lpad36 ], [ %245, %lpad46 ]
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %91) #16
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %90) #16
  call void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* nonnull %tree.i) #16
  br label %ehcleanup85

ehcleanup85:                                      ; preds = %ehcleanup78, %lpad.i95
  %ehselector.slot.6 = phi i32 [ %ehselector.slot.5, %ehcleanup78 ], [ %89, %lpad.i95 ]
  %exn.slot.6 = phi i8* [ %exn.slot.5, %ehcleanup78 ], [ %88, %lpad.i95 ]
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %85) #16
  %bf.load.i.i.i.i376 = load i8, i8* %small_n.i.i.i.i80, align 2
  %cmp.i.i.i.i377 = icmp sgt i8 %bf.load.i.i.i.i376, -1
  br i1 %cmp.i.i.i.i377, label %ehcleanup87.tf, label %if.then.i.i.i381

if.then.i.i.i381:                                 ; preds = %ehcleanup85
  %buffer.i.i.i.i378 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %init, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %298 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i378, align 8, !tbaa !2
  %capacity.i.i.i.i.i379 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %298, i64 0, i32 0
  %299 = load i64, i64* %capacity.i.i.i.i.i379, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i380 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i384 unwind label %lpad.i.i386

call.i.i.i.i.i.noexc.i.i384:                      ; preds = %if.then.i.i.i381
  %300 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %298 to i8*
  %mul.i.i.i.i.i382 = shl i64 %299, 3
  %add.i.i.i.i.i383 = add i64 %mul.i.i.i.i.i382, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i380, i8* %300, i64 %add.i.i.i.i.i383)
          to label %.noexc.i.i385 unwind label %lpad.i.i386

.noexc.i.i385:                                    ; preds = %call.i.i.i.i.i.noexc.i.i384
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i378, align 8, !tbaa !2
  br label %ehcleanup87.tf

lpad.i.i386:                                      ; preds = %call.i.i.i.i.i.noexc.i.i384, %if.then.i.i.i381
  %301 = landingpad { i8*, i32 }
          catch i8* null
  %302 = extractvalue { i8*, i32 } %301, 0
  call void @__clang_call_terminate(i8* %302) #17
  unreachable

ehcleanup87.tf:                                   ; preds = %.noexc.i.i385, %ehcleanup85
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %83) #16
  %bf.load.i.i393 = load i8, i8* %small_n.i.i.i.i.i.i, align 2
  %cmp.i.i394 = icmp sgt i8 %bf.load.i.i393, -1
  %tf.i425 = call token @llvm.taskframe.create()
  %syncreg19.i.i.i391 = call token @llvm.syncregion.start()
  br i1 %cmp.i.i394, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit390, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i401

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i401: ; preds = %ehcleanup87.tf
  %bf.load.i1.i.i.i396 = load i48, i48* %ref.tmp.sroa.4.0..sroa_cast6.i.i.i.i, align 8
  %bf.cast.i.i.i.i397 = zext i48 %bf.load.i1.i.i.i396 to i64
  %buffer.i.i.i.i.i398 = getelementptr inbounds %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981", %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"* %VQ, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %303 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i398, align 8, !tbaa !40
  %data.i.i.i.i.i.i399 = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %303, i64 0, i32 1, i32 0
  %304 = bitcast [1 x i8]* %data.i.i.i.i.i.i399 to %struct.Qs.63.374.681.988.1295.1602.1909*
  %cmp1.i.i.i400 = icmp eq i48 %bf.load.i1.i.i.i396, 0
  br i1 %cmp1.i.i.i400, label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i423, label %pfor.cond.i.i.i404.preheader

pfor.cond.i.i.i404.preheader:                     ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i401
  %305 = add nsw i64 %bf.cast.i.i.i.i397, -1
  %xtraiter7 = and i64 %bf.cast.i.i.i.i397, 2047
  %306 = icmp ult i64 %305, 2047
  br i1 %306, label %pfor.cond.cleanup.i.i.i417.strpm-lcssa, label %pfor.cond.i.i.i404.preheader.new

pfor.cond.i.i.i404.preheader.new:                 ; preds = %pfor.cond.i.i.i404.preheader
  %stripiter10 = lshr i64 %bf.cast.i.i.i.i397, 11
  br label %pfor.cond.i.i.i404.strpm.outer

pfor.cond.i.i.i404.strpm.outer:                   ; preds = %pfor.inc.i.i.i416.strpm.outer, %pfor.cond.i.i.i404.preheader.new
  %niter11 = phi i64 [ 0, %pfor.cond.i.i.i404.preheader.new ], [ %niter11.nadd, %pfor.inc.i.i.i416.strpm.outer ]
  detach within %syncreg19.i.i.i391, label %pfor.body.i.i.i407.strpm.outer, label %pfor.inc.i.i.i416.strpm.outer

pfor.body.i.i.i407.strpm.outer:                   ; preds = %pfor.cond.i.i.i404.strpm.outer
  %307 = shl i64 %niter11, 11
  br label %pfor.cond.i.i.i404

pfor.cond.i.i.i404:                               ; preds = %pfor.inc.i.i.i416, %pfor.body.i.i.i407.strpm.outer
  %__begin.0.i.i.i403 = phi i64 [ %inc.i.i.i414, %pfor.inc.i.i.i416 ], [ %307, %pfor.body.i.i.i407.strpm.outer ]
  %inneriter12 = phi i64 [ %inneriter12.nsub, %pfor.inc.i.i.i416 ], [ 2048, %pfor.body.i.i.i407.strpm.outer ]
  %_M_start.i.i.i.i.i.i.i.i.i.i.i405 = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %304, i64 %__begin.0.i.i.i403, i32 1, i32 0, i32 0, i32 0, i32 0
  %308 = load %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904** %_M_start.i.i.i.i.i.i.i.i.i.i.i405, align 8, !tbaa !42
  %tobool.i.i.i.i.i.i.i.i.i.i.i.i406 = icmp eq %struct.simplex.58.369.676.983.1290.1597.1904* %308, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i.i.i406, label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411, label %if.then.i.i.i.i.i.i.i.i.i.i.i.i408

if.then.i.i.i.i.i.i.i.i.i.i.i.i408:               ; preds = %pfor.cond.i.i.i404
  %309 = bitcast %struct.simplex.58.369.676.983.1290.1597.1904* %308 to i8*
  call void @_ZdlPv(i8* nonnull %309) #16
  br label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411

_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i.i408, %pfor.cond.i.i.i404
  %_M_start.i.i1.i.i.i.i.i.i.i.i.i409 = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %304, i64 %__begin.0.i.i.i403, i32 0, i32 0, i32 0, i32 0, i32 0
  %310 = load %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898*** %_M_start.i.i1.i.i.i.i.i.i.i.i.i409, align 8, !tbaa !44
  %tobool.i.i.i2.i.i.i.i.i.i.i.i.i410 = icmp eq %struct.vertex.52.363.670.977.1284.1591.1898** %310, null
  br i1 %tobool.i.i.i2.i.i.i.i.i.i.i.i.i410, label %pfor.inc.i.i.i416, label %if.then.i.i.i3.i.i.i.i.i.i.i.i.i412

if.then.i.i.i3.i.i.i.i.i.i.i.i.i412:              ; preds = %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411
  %311 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %310 to i8*
  call void @_ZdlPv(i8* nonnull %311) #16
  br label %pfor.inc.i.i.i416

pfor.inc.i.i.i416:                                ; preds = %if.then.i.i.i3.i.i.i.i.i.i.i.i.i412, %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411
  %inc.i.i.i414 = add nuw nsw i64 %__begin.0.i.i.i403, 1
  %inneriter12.nsub = add nsw i64 %inneriter12, -1
  %inneriter12.ncmp = icmp eq i64 %inneriter12.nsub, 0
  br i1 %inneriter12.ncmp, label %pfor.inc.i.i.i416.reattach, label %pfor.cond.i.i.i404, !llvm.loop !79

pfor.inc.i.i.i416.reattach:                       ; preds = %pfor.inc.i.i.i416
  reattach within %syncreg19.i.i.i391, label %pfor.inc.i.i.i416.strpm.outer

pfor.inc.i.i.i416.strpm.outer:                    ; preds = %pfor.inc.i.i.i416.reattach, %pfor.cond.i.i.i404.strpm.outer
  %niter11.nadd = add nuw nsw i64 %niter11, 1
  %niter11.ncmp = icmp eq i64 %niter11.nadd, %stripiter10
  br i1 %niter11.ncmp, label %pfor.cond.cleanup.i.i.i417.strpm-lcssa, label %pfor.cond.i.i.i404.strpm.outer, !llvm.loop !80

pfor.cond.cleanup.i.i.i417.strpm-lcssa:           ; preds = %pfor.inc.i.i.i416.strpm.outer, %pfor.cond.i.i.i404.preheader
  %lcmp.mod13 = icmp eq i64 %xtraiter7, 0
  br i1 %lcmp.mod13, label %pfor.cond.cleanup.i.i.i417, label %pfor.cond.i.i.i404.epil.preheader

pfor.cond.i.i.i404.epil.preheader:                ; preds = %pfor.cond.cleanup.i.i.i417.strpm-lcssa
  %312 = and i64 %bf.cast.i.i.i.i397, 281474976708608
  br label %pfor.cond.i.i.i404.epil

pfor.cond.i.i.i404.epil:                          ; preds = %pfor.inc.i.i.i416.epil, %pfor.cond.i.i.i404.epil.preheader
  %__begin.0.i.i.i403.epil = phi i64 [ %inc.i.i.i414.epil, %pfor.inc.i.i.i416.epil ], [ %312, %pfor.cond.i.i.i404.epil.preheader ]
  %epil.iter8 = phi i64 [ %epil.iter8.sub, %pfor.inc.i.i.i416.epil ], [ %xtraiter7, %pfor.cond.i.i.i404.epil.preheader ]
  %_M_start.i.i.i.i.i.i.i.i.i.i.i405.epil = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %304, i64 %__begin.0.i.i.i403.epil, i32 1, i32 0, i32 0, i32 0, i32 0
  %313 = load %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904** %_M_start.i.i.i.i.i.i.i.i.i.i.i405.epil, align 8, !tbaa !42
  %tobool.i.i.i.i.i.i.i.i.i.i.i.i406.epil = icmp eq %struct.simplex.58.369.676.983.1290.1597.1904* %313, null
  br i1 %tobool.i.i.i.i.i.i.i.i.i.i.i.i406.epil, label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411.epil, label %if.then.i.i.i.i.i.i.i.i.i.i.i.i408.epil

if.then.i.i.i.i.i.i.i.i.i.i.i.i408.epil:          ; preds = %pfor.cond.i.i.i404.epil
  %314 = bitcast %struct.simplex.58.369.676.983.1290.1597.1904* %313 to i8*
  call void @_ZdlPv(i8* nonnull %314) #16
  br label %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411.epil

_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411.epil: ; preds = %if.then.i.i.i.i.i.i.i.i.i.i.i.i408.epil, %pfor.cond.i.i.i404.epil
  %_M_start.i.i1.i.i.i.i.i.i.i.i.i409.epil = getelementptr inbounds %struct.Qs.63.374.681.988.1295.1602.1909, %struct.Qs.63.374.681.988.1295.1602.1909* %304, i64 %__begin.0.i.i.i403.epil, i32 0, i32 0, i32 0, i32 0, i32 0
  %315 = load %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898*** %_M_start.i.i1.i.i.i.i.i.i.i.i.i409.epil, align 8, !tbaa !44
  %tobool.i.i.i2.i.i.i.i.i.i.i.i.i410.epil = icmp eq %struct.vertex.52.363.670.977.1284.1591.1898** %315, null
  br i1 %tobool.i.i.i2.i.i.i.i.i.i.i.i.i410.epil, label %pfor.inc.i.i.i416.epil, label %if.then.i.i.i3.i.i.i.i.i.i.i.i.i412.epil

if.then.i.i.i3.i.i.i.i.i.i.i.i.i412.epil:         ; preds = %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411.epil
  %316 = bitcast %struct.vertex.52.363.670.977.1284.1591.1898** %315 to i8*
  call void @_ZdlPv(i8* nonnull %316) #16
  br label %pfor.inc.i.i.i416.epil

pfor.inc.i.i.i416.epil:                           ; preds = %if.then.i.i.i3.i.i.i.i.i.i.i.i.i412.epil, %_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EED2Ev.exit.i.i.i.i.i.i.i.i.i411.epil
  %inc.i.i.i414.epil = add nuw nsw i64 %__begin.0.i.i.i403.epil, 1
  %epil.iter8.sub = add nsw i64 %epil.iter8, -1
  %epil.iter8.cmp = icmp eq i64 %epil.iter8.sub, 0
  br i1 %epil.iter8.cmp, label %pfor.cond.cleanup.i.i.i417, label %pfor.cond.i.i.i404.epil, !llvm.loop !81

pfor.cond.cleanup.i.i.i417:                       ; preds = %pfor.inc.i.i.i416.epil, %pfor.cond.cleanup.i.i.i417.strpm-lcssa
  sync within %syncreg19.i.i.i391, label %sync.continue.i.i.i418

sync.continue.i.i.i418:                           ; preds = %pfor.cond.cleanup.i.i.i417
  invoke void @llvm.sync.unwind(token %syncreg19.i.i.i391)
          to label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i423 unwind label %lpad.i.i389426

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i423: ; preds = %sync.continue.i.i.i418, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl4dataEv.exit.i.i401
  %317 = load %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"*, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i398, align 8, !tbaa !40
  %capacity.i.i.i420 = getelementptr inbounds %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974", %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %317, i64 0, i32 0
  %318 = load i64, i64* %capacity.i.i.i420, align 8, !tbaa !38
  %call.i.i.i.i.i430 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc429 unwind label %lpad.i.i389426

call.i.i.i.i.i.noexc429:                          ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i423
  %319 = bitcast %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* %317 to i8*
  %mul.i.i.i421 = mul i64 %318, 48
  %add.i.i.i422 = or i64 %mul.i.i.i421, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i430, i8* %319, i64 %add.i.i.i422)
          to label %.noexc431 unwind label %lpad.i.i389426

.noexc431:                                        ; preds = %call.i.i.i.i.i.noexc429
  store %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"* null, %"struct.parlay::_sequence_base<Qs<point2d<double> >, parlay::allocator<Qs<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.128.439.746.1053.1360.1667.1974"** %buffer.i.i.i.i.i398, align 8, !tbaa !40
  br label %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit390

lpad.i.i389.unreachable:                          ; preds = %lpad.i.i389426
  unreachable

lpad.i.i389426:                                   ; preds = %call.i.i.i.i.i.noexc429, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl11destroy_allEv.exit.i423, %sync.continue.i.i.i418
  %320 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.taskframe.resume.sl_p0i8i32s(token %tf.i425, { i8*, i32 } %320)
          to label %lpad.i.i389.unreachable unwind label %lpad.i.i389

lpad.i.i389:                                      ; preds = %lpad.i.i389426
  %321 = landingpad { i8*, i32 }
          catch i8* null
  %322 = extractvalue { i8*, i32 } %321, 0
  call void @__clang_call_terminate(i8* %322) #17
  unreachable

_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit390: ; preds = %.noexc431, %ehcleanup87.tf
  store i8 0, i8* %small_n.i.i.i.i.i.i, align 2
  call void @llvm.taskframe.end(token %tf.i425)
  br label %ehcleanup89

ehcleanup89:                                      ; preds = %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit390, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i.i.i
  %ehselector.slot.8 = phi i32 [ %ehselector.slot.6, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit390 ], [ %ehselector.slot.0.i.i.i, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i.i.i ]
  %exn.slot.8 = phi i8* [ %exn.slot.6, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit390 ], [ %exn.slot.0.i.i.i, %_ZN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i.i.i ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %47) #16
  %bf.load.i.i.i.i434 = load i8, i8* %small_n.i.i.i.i58, align 2
  %cmp.i.i.i.i435 = icmp sgt i8 %bf.load.i.i.i.i434, -1
  br i1 %cmp.i.i.i.i435, label %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit444, label %if.then.i.i.i439

if.then.i.i.i439:                                 ; preds = %ehcleanup89
  %buffer.i.i.i.i436 = getelementptr inbounds %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036", %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"* %flags, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %323 = load %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"*, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i436, align 8, !tbaa !29
  %capacity.i.i.i.i.i437 = getelementptr inbounds %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029", %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %323, i64 0, i32 0
  %324 = load i64, i64* %capacity.i.i.i.i.i437, align 8, !tbaa !31
  %call.i.i.i.i.i1.i.i438 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i441 unwind label %lpad.i.i443

call.i.i.i.i.i.noexc.i.i441:                      ; preds = %if.then.i.i.i439
  %325 = bitcast %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* %323 to i8*
  %add.i.i.i.i.i440 = add i64 %324, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i438, i8* %325, i64 %add.i.i.i.i.i440)
          to label %.noexc.i.i442 unwind label %lpad.i.i443

.noexc.i.i442:                                    ; preds = %call.i.i.i.i.i.noexc.i.i441
  store %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"* null, %"struct.parlay::_sequence_base<bool, parlay::allocator<bool> >::_sequence_impl::capacitated_buffer::header.184.494.801.1108.1415.1722.2029"** %buffer.i.i.i.i436, align 8, !tbaa !29
  br label %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit444

lpad.i.i443:                                      ; preds = %call.i.i.i.i.i.noexc.i.i441, %if.then.i.i.i439
  %326 = landingpad { i8*, i32 }
          catch i8* null
  %327 = extractvalue { i8*, i32 } %326, 0
  call void @__clang_call_terminate(i8* %327) #17
  unreachable

_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit444: ; preds = %.noexc.i.i442, %ehcleanup89
  store i8 0, i8* %small_n.i.i.i.i58, align 2
  br label %ehcleanup91

ehcleanup91:                                      ; preds = %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit444, %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit.i
  %ehselector.slot.9 = phi i32 [ %ehselector.slot.8, %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit444 ], [ %46, %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit.i ]
  %exn.slot.9 = phi i8* [ %exn.slot.8, %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit444 ], [ %45, %_ZN6parlay14_sequence_baseIbNS_9allocatorIbEEED2Ev.exit.i ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %38) #16
  %bf.load.i.i.i.i446 = load i8, i8* %small_n.i.i.i.i44, align 2
  %cmp.i.i.i.i447 = icmp sgt i8 %bf.load.i.i.i.i446, -1
  br i1 %cmp.i.i.i.i447, label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit457, label %if.then.i.i.i451

if.then.i.i.i451:                                 ; preds = %ehcleanup91
  %328 = load %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"*, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i500, align 8, !tbaa !27
  %capacity.i.i.i.i.i449 = getelementptr inbounds %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965", %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %328, i64 0, i32 0
  %329 = load i64, i64* %capacity.i.i.i.i.i449, align 8, !tbaa !10
  %call.i.i.i.i.i1.i.i450 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i454 unwind label %lpad.i.i456

call.i.i.i.i.i.noexc.i.i454:                      ; preds = %if.then.i.i.i451
  %330 = bitcast %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* %328 to i8*
  %mul.i.i.i.i.i452 = shl i64 %329, 4
  %add.i.i.i.i.i453 = or i64 %mul.i.i.i.i.i452, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i450, i8* %330, i64 %add.i.i.i.i.i453)
          to label %.noexc.i.i455 unwind label %lpad.i.i456

.noexc.i.i455:                                    ; preds = %call.i.i.i.i.i.noexc.i.i454
  store %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"* null, %"struct.parlay::_sequence_base<simplex<point2d<double> >, parlay::allocator<simplex<point2d<double> > > >::_sequence_impl::capacitated_buffer::header.119.430.737.1044.1351.1658.1965"** %buffer.i.i.i.i500, align 8, !tbaa !27
  br label %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit457

lpad.i.i456:                                      ; preds = %call.i.i.i.i.i.noexc.i.i454, %if.then.i.i.i451
  %331 = landingpad { i8*, i32 }
          catch i8* null
  %332 = extractvalue { i8*, i32 } %331, 0
  call void @__clang_call_terminate(i8* %332) #17
  unreachable

_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit457: ; preds = %.noexc.i.i455, %ehcleanup91
  store i8 0, i8* %small_n.i.i.i.i44, align 2
  br label %ehcleanup93

ehcleanup93:                                      ; preds = %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit457, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i
  %ehselector.slot.10 = phi i32 [ %ehselector.slot.9, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit457 ], [ %37, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i ]
  %exn.slot.10 = phi i8* [ %exn.slot.9, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit457 ], [ %36, %_ZN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEED2Ev.exit.i ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %19) #16
  %bf.load.i.i.i.i459 = load i8, i8* %small_n.i.i.i.i43, align 2
  %cmp.i.i.i.i460 = icmp sgt i8 %bf.load.i.i.i.i459, -1
  br i1 %cmp.i.i.i.i460, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit470, label %if.then.i.i.i464

if.then.i.i.i464:                                 ; preds = %ehcleanup93
  %buffer.i.i.i.i461 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %remain, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %333 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i461, align 8, !tbaa !2
  %capacity.i.i.i.i.i462 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %333, i64 0, i32 0
  %334 = load i64, i64* %capacity.i.i.i.i.i462, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i463 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i467 unwind label %lpad.i.i469

call.i.i.i.i.i.noexc.i.i467:                      ; preds = %if.then.i.i.i464
  %335 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %333 to i8*
  %mul.i.i.i.i.i465 = shl i64 %334, 3
  %add.i.i.i.i.i466 = add i64 %mul.i.i.i.i.i465, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i463, i8* %335, i64 %add.i.i.i.i.i466)
          to label %.noexc.i.i468 unwind label %lpad.i.i469

.noexc.i.i468:                                    ; preds = %call.i.i.i.i.i.noexc.i.i467
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i461, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit470

lpad.i.i469:                                      ; preds = %call.i.i.i.i.i.noexc.i.i467, %if.then.i.i.i464
  %336 = landingpad { i8*, i32 }
          catch i8* null
  %337 = extractvalue { i8*, i32 } %336, 0
  call void @__clang_call_terminate(i8* %337) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit470: ; preds = %.noexc.i.i468, %ehcleanup93
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %18) #16
  %bf.load.i.i.i.i472 = load i8, i8* %small_n.i.i.i.i28, align 2
  %cmp.i.i.i.i473 = icmp sgt i8 %bf.load.i.i.i.i472, -1
  br i1 %cmp.i.i.i.i473, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit483, label %if.then.i.i.i477

if.then.i.i.i477:                                 ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit470
  %buffer.i.i.i.i474 = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %buffer, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %338 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i474, align 8, !tbaa !2
  %capacity.i.i.i.i.i475 = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %338, i64 0, i32 0
  %339 = load i64, i64* %capacity.i.i.i.i.i475, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i476 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i480 unwind label %lpad.i.i482

call.i.i.i.i.i.noexc.i.i480:                      ; preds = %if.then.i.i.i477
  %340 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %338 to i8*
  %mul.i.i.i.i.i478 = shl i64 %339, 3
  %add.i.i.i.i.i479 = add i64 %mul.i.i.i.i.i478, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i476, i8* %340, i64 %add.i.i.i.i.i479)
          to label %.noexc.i.i481 unwind label %lpad.i.i482

.noexc.i.i481:                                    ; preds = %call.i.i.i.i.i.noexc.i.i480
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i474, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit483

lpad.i.i482:                                      ; preds = %call.i.i.i.i.i.noexc.i.i480, %if.then.i.i.i477
  %341 = landingpad { i8*, i32 }
          catch i8* null
  %342 = extractvalue { i8*, i32 } %341, 0
  call void @__clang_call_terminate(i8* %342) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit483: ; preds = %.noexc.i.i481, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit470
  store i8 0, i8* %small_n.i.i.i.i28, align 2
  br label %ehcleanup97

ehcleanup97:                                      ; preds = %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit483, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i41
  %ehselector.slot.12 = phi i32 [ %ehselector.slot.10, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit483 ], [ %17, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i41 ]
  %exn.slot.12 = phi i8* [ %exn.slot.10, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit483 ], [ %16, %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit.i41 ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %9) #16
  %bf.load.i.i.i.i = load i8, i8* %small_n.i.i.i.i, align 2
  %cmp.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i, -1
  br i1 %cmp.i.i.i.i, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %ehcleanup97
  %buffer.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954", %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* %done, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %343 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i, align 8, !tbaa !2
  %capacity.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %343, i64 0, i32 0
  %344 = load i64, i64* %capacity.i.i.i.i.i, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i:                         ; preds = %if.then.i.i.i
  %345 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %343 to i8*
  %mul.i.i.i.i.i = shl i64 %344, 3
  %add.i.i.i.i.i = add i64 %mul.i.i.i.i.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i, i8* %345, i64 %add.i.i.i.i.i)
          to label %.noexc.i.i unwind label %lpad.i.i

.noexc.i.i:                                       ; preds = %call.i.i.i.i.i.noexc.i.i
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i, align 8, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit

lpad.i.i:                                         ; preds = %call.i.i.i.i.i.noexc.i.i, %if.then.i.i.i
  %346 = landingpad { i8*, i32 }
          catch i8* null
  %347 = extractvalue { i8*, i32 } %346, 0
  call void @__clang_call_terminate(i8* %347) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit: ; preds = %.noexc.i.i, %ehcleanup97
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %2) #16
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.12, 0
  %lpad.val102 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.12, 1
  resume { i8*, i32 } %lpad.val102
}

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev(%"struct.parlay::_sequence_base.29.107.418.725.1032.1339.1646.1953"*) unnamed_addr #8 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEEES6_E3$_4EEvmmT_mb"(i64, %class.anon.52.136.447.754.1061.1368.1675.1982* nocapture readonly byval(%class.anon.52.136.447.754.1061.1368.1675.1982) align 8) unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_Z8delaunayRN6parlay8sequenceI7point2dIdENS_9allocatorIS2_EEEE(%struct.triangles.146.457.764.1071.1378.1685.1992* noalias nocapture sret, %"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"* dereferenceable(15)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay18random_permutationImEENS_8sequenceIT_NS_9allocatorIS2_EEEEmNS_6randomE(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* noalias sret, i64, i64) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN5timer4nextENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.timer.5.316.623.930.1237.1544.1851*, %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @__cxx_global_var_init.8() #4 section ".text.startup"

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay15block_allocatorC2Emmmm(%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*, i64, i64, i64, i64) unnamed_addr #4 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZN6parlay15block_allocatorD2Ev(%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*) unnamed_addr #8 align 2

; Function Attrs: noreturn
declare dso_local void @_ZSt19__throw_logic_errorPKc(i8*) local_unnamed_addr #9

declare dso_local i8* @_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE9_M_createERmm(%"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"*, i64* dereferenceable(8), i64) local_unnamed_addr #0

declare dso_local i8* @__cxa_begin_catch(i8*) local_unnamed_addr

; Function Attrs: noinline noreturn nounwind
declare hidden void @__clang_call_terminate(i8*) local_unnamed_addr #10

declare dso_local void @_ZSt9terminatev() local_unnamed_addr

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPv(i8*) local_unnamed_addr #11

; Function Attrs: sanitize_cilk uwtable
declare dso_local i64 @_ZN6parlay8internal6reduceINS_5sliceIPKmS4_EENS_4addmImEEEENT_10value_typeERKS8_T0_j(%"struct.parlay::slice.76.147.458.765.1072.1379.1686.1993"* dereferenceable(16), i64, i32) local_unnamed_addr #4

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.ceil.f64(double) #12

; Function Attrs: sanitize_cilk uwtable
declare dso_local i64 @_ZN6parlay8internal6reduceINS_8sequenceImNS_9allocatorImEEEENS_4addmImEEEENT_10value_typeERKS8_T0_j(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* dereferenceable(15), i64, i32) local_unnamed_addr #4

; Function Attrs: nofree nounwind
declare dso_local double @sqrt(double) local_unnamed_addr #7

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceImNS_9allocatorImEEE18initialize_defaultEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEE18initialize_defaultEmEUlmE_EEvmmT_mb(i64, i64, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64**, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv() local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local i8* @_ZN6parlay14pool_allocator8allocateEm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: nofree nounwind
declare dso_local i32 @__cxa_guard_acquire(i64*) local_unnamed_addr #2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14pool_allocatorC2ERKSt6vectorImSaImEE(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"*, %"class.std::vector.90.49.360.667.974.1281.1588.1895"* dereferenceable(24)) unnamed_addr #4 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZNSt6vectorImSaImEED2Ev(%"class.std::vector.90.49.360.667.974.1281.1588.1895"*) unnamed_addr #8 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14pool_allocatorD2Ev(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"*) unnamed_addr #8 align 2

; Function Attrs: nofree nounwind
declare dso_local void @__cxa_guard_abort(i64*) local_unnamed_addr #2

; Function Attrs: nofree nounwind
declare dso_local void @__cxa_guard_release(i64*) local_unnamed_addr #2

; Function Attrs: nounwind
declare dso_local i64 @sysconf(i32) local_unnamed_addr #1

; Function Attrs: noreturn
declare dso_local void @_ZSt20__throw_length_errorPKc(i8*) local_unnamed_addr #9

; Function Attrs: noreturn
declare dso_local void @_ZSt17__throw_bad_allocv() local_unnamed_addr #9

; Function Attrs: nobuiltin nofree
declare dso_local noalias nonnull i8* @_Znwm(i64) local_unnamed_addr #13

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memmove.p0i8.p0i8.i64(i8* nocapture, i8* nocapture readonly, i64, i1 immarg) #3

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZNSt10unique_ptrIA_N6parlay16concurrent_stackIPvEESt14default_deleteIS4_EED2Ev(%"class.std::unique_ptr.81.45.356.663.970.1277.1584.1891"*) unnamed_addr #8 align 2

; Function Attrs: nobuiltin nofree
declare dso_local noalias i8* @_ZnwmSt11align_val_t(i64, i64) local_unnamed_addr #13

declare dso_local i8* @__cxa_allocate_exception(i64) local_unnamed_addr

declare dso_local void @_ZNSt16invalid_argumentC1EPKc(%"class.std::invalid_argument.152.463.770.1077.1384.1691.1998"*, i8*) unnamed_addr #0

declare dso_local void @__cxa_free_exception(i8*) local_unnamed_addr

; Function Attrs: nounwind
declare dso_local void @_ZNSt16invalid_argumentD1Ev(%"class.std::invalid_argument.152.463.770.1077.1384.1691.1998"*) unnamed_addr #1

declare dso_local void @__cxa_throw(i8*, i8*, i8*) local_unnamed_addr

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memset.p0i8.i64(i8* nocapture writeonly, i8, i64, i1 immarg) #3

; Function Attrs: nounwind readnone speculatable willreturn
declare { i64, i1 } @llvm.umul.with.overflow.i64(i64, i64) #12

; Function Attrs: nobuiltin nofree
declare dso_local noalias i8* @_ZnamSt11align_val_t(i64, i64) local_unnamed_addr #13

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdaPvSt11align_val_t(i8*, i64) local_unnamed_addr #11

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPvE5clearEv(%"class.parlay::concurrent_stack.89.39.350.657.964.1271.1578.1885"*) local_unnamed_addr #4 align 2

; Function Attrs: noreturn
declare dso_local void @_ZSt20__throw_system_errori(i32) local_unnamed_addr #9

; Function Attrs: nounwind
declare extern_weak dso_local i32 @__csan_pthread_mutex_lock(%union.pthread_mutex_t.24.335.642.949.1256.1563.1870*) local_unnamed_addr #1

; Function Attrs: nounwind
declare extern_weak dso_local i32 @__pthread_key_create(i32*, void (i8*)*) #1

; Function Attrs: nounwind
declare extern_weak dso_local i32 @__csan_pthread_mutex_unlock(%union.pthread_mutex_t.24.335.642.949.1256.1563.1870*) local_unnamed_addr #1

; Function Attrs: nobuiltin nounwind
declare dso_local void @_ZdlPvSt11align_val_t(i8*, i64) local_unnamed_addr #11

; Function Attrs: sanitize_cilk uwtable
declare dso_local { i8*, i8 } @_ZN6parlay16concurrent_stackIPvE3popEv(%"class.parlay::concurrent_stack.89.39.350.657.964.1271.1578.1885"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local i8* @_ZN6parlay14pool_allocator14allocate_largeEm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: nounwind
declare dso_local void @_ZNSt9bad_allocD1Ev(%"class.std::bad_alloc.153.464.771.1078.1385.1692.1999"*) unnamed_addr #1

; Function Attrs: sanitize_cilk uwtable
declare dso_local %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* @_ZN6parlay15block_allocator8get_listEv(%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*) local_unnamed_addr #4 align 2

declare dso_local i32 @__cilkrts_get_worker_number() local_unnamed_addr #0

; Function Attrs: sanitize_cilk uwtable
declare dso_local { %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, i8 } @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE3popEv(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPcE4pushES1_(%"class.parlay::concurrent_stack.28.339.646.953.1260.1567.1874"*, i8*) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_15block_allocator15initialize_listEPNS1_5blockEEUlmE_EEvmmT_mb(i64, i64, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"**, %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.syncregion.start() #3

; Function Attrs: argmemonly willreturn
declare void @llvm.sync.unwind(token) #14

; Function Attrs: argmemonly nounwind willreturn
declare token @llvm.taskframe.create() #3

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.use(token) #3

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"*, i8*, i64) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPvE4pushES1_(%"class.parlay::concurrent_stack.89.39.350.657.964.1271.1578.1885"*, i8*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE4pushES3_(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_5sliceIPKmS6_EENS_4addmImEEEENT_10value_typeERKSA_T0_jEUlmmmE_EEvmmSD_jEUlmE_EEvmmSA_mb(i64, i64, %class.anon.106.156.467.774.1081.1388.1695.2002* byval(%class.anon.106.156.467.774.1081.1388.1695.2002) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_8sequenceImNS_9allocatorImEEEENS_4addmImEEEENT_10value_typeERKSA_T0_jEUlmmmE_EEvmmSD_jEUlmE_EEvmmSA_mb(i64, i64, %class.anon.108.158.469.776.1083.1390.1697.2004* byval(%class.anon.108.158.469.776.1083.1390.1697.2004) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceI7point2dIdENS_9allocatorIS2_EEEC2Em(%"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"*, i64) unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local fastcc { double, double } @"_ZN6parlay8internal6reduceINS_8sequenceI7point2dIdENS_9allocatorIS4_EEEENS_6monoidIZ17generate_boundaryRKS7_mRNS2_I6vertexIS4_ENS5_ISC_EEEERNS2_I8triangleIS4_ENS5_ISH_EEEEE3$_1S4_EEEENT_10value_typeERKSN_T0_j"(%"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"* dereferenceable(15), %"struct.parlay::monoid.161.471.778.1085.1392.1699.2006"* byval(%"struct.parlay::monoid.161.471.778.1085.1392.1699.2006") align 8) unnamed_addr #4

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_5sliceIPK7point2dIdES8_EENS_6monoidIZ17generate_boundaryRKNS_8sequenceIS6_NS_9allocatorIS6_EEEEmRNSB_I6vertexIS6_ENSC_ISI_EEEERNSB_I8triangleIS6_ENSC_ISN_EEEEE3$_1S6_EEEENT_10value_typeERKST_T0_jEUlmmmE_EEvmmSW_jEUlmE_EEvmmST_mb"(i64, i64, i64*, i64*, %class.anon.110.163.473.780.1087.1394.1701.2008*) unnamed_addr #5

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_8sequenceI7point2dIdENS_9allocatorIS6_EEEENS_6monoidIZ17generate_boundaryRKS9_mRNS4_I6vertexIS6_ENS7_ISE_EEEERNS4_I8triangleIS6_ENS7_ISJ_EEEEE3$_1S6_EEEENT_10value_typeERKSP_T0_jEUlmmmE_EEvmmSS_jEUlmE_EEvmmSP_mb"(i64, i64, i64*, i64*, %class.anon.113.164.474.781.1088.1395.1702.2009*) unnamed_addr #5

; Function Attrs: sanitize_cilk uwtable
declare dso_local fastcc { double, double } @"_ZN6parlay8internal6reduceINS_8sequenceI7point2dIdENS_9allocatorIS4_EEEENS_6monoidIZ17generate_boundaryRKS7_mRNS2_I6vertexIS4_ENS5_ISC_EEEERNS2_I8triangleIS4_ENS5_ISH_EEEEE3$_2S4_EEEENT_10value_typeERKSN_T0_j"(%"class.parlay::sequence.14.90.401.708.1015.1322.1629.1936"* dereferenceable(15), %"struct.parlay::monoid.27.166.476.783.1090.1397.1704.2011"* byval(%"struct.parlay::monoid.27.166.476.783.1090.1397.1704.2011") align 8) unnamed_addr #4

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_5sliceIPK7point2dIdES8_EENS_6monoidIZ17generate_boundaryRKNS_8sequenceIS6_NS_9allocatorIS6_EEEEmRNSB_I6vertexIS6_ENSC_ISI_EEEERNSB_I8triangleIS6_ENSC_ISN_EEEEE3$_2S6_EEEENT_10value_typeERKST_T0_jEUlmmmE_EEvmmSW_jEUlmE_EEvmmST_mb"(i64, i64, i64*, i64*, %class.anon.115.167.477.784.1091.1398.1705.2012*) unnamed_addr #5

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_8sequenceI7point2dIdENS_9allocatorIS6_EEEENS_6monoidIZ17generate_boundaryRKS9_mRNS4_I6vertexIS6_ENS7_ISE_EEEERNS4_I8triangleIS6_ENS7_ISJ_EEEEE3$_2S6_EEEENT_10value_typeERKSP_T0_jEUlmmmE_EEvmmSS_jEUlmE_EEvmmSP_mb"(i64, i64, i64*, i64*, %class.anon.117.168.478.785.1092.1399.1706.2013*) unnamed_addr #5

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8sequenceI2QsI7point2dIdEENS_9allocatorIS5_EEEC1IRZ24incrementally_add_pointsNS1_IP6vertexIS4_ENS6_ISC_EEEESC_E3$_3EEmOT_NS8_18_from_function_tagEmEUlmE_EEvmmSH_mb"(i64, %"class.parlay::sequence.43.135.446.753.1060.1367.1674.1981"*, %struct.Qs.63.374.681.988.1295.1602.1909**, %class.anon.48.169.479.786.1093.1400.1707.2014*) unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN2QsI7point2dIdEEC2Ev(%struct.Qs.63.374.681.988.1295.1602.1909*) unnamed_addr #4 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local dereferenceable(8) %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEEaSEOS8_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"*, %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* dereferenceable(8)) local_unnamed_addr #8 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this) unnamed_addr #8 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
entry:
  %syncreg.i = tail call token @llvm.syncregion.start()
  %n = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 0
  %0 = load i64, i64* %n, align 8, !tbaa !82
  %cmp = icmp ugt i64 %0, 1000
  br i1 %cmp, label %if.then.i, label %if.else.i

if.then.i:                                        ; preds = %entry
  detach within %syncreg.i, label %det.achd.i, label %det.cont.i unwind label %lpad

det.achd.i:                                       ; preds = %if.then.i
  %R.i.i7 = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 3
  %1 = load %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %R.i.i7, align 8, !tbaa !88
  %cmp.i19 = icmp eq %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %1, null
  br i1 %cmp.i19, label %.noexc10, label %if.then.i20

if.then.i20:                                      ; preds = %det.achd.i
  tail call void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* nonnull %1) #16
  %call.i.i.i.i73 = invoke i32 @__cilkrts_get_worker_number()
          to label %call.i.i.i.i.noexc72 unwind label %lpad9

call.i.i.i.i.noexc72:                             ; preds = %if.then.i20
  %conv.i.i.i.i53 = zext i32 %call.i.i.i.i73 to i64
  %2 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %sz.i.i.i54 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %2, i64 %conv.i.i.i.i53, i32 0
  %3 = load i64, i64* %sz.i.i.i54, align 64, !tbaa !97
  %4 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %add.i.i.i55 = add i64 %4, 1
  %cmp.i.i.i56 = icmp eq i64 %3, %add.i.i.i55
  br i1 %cmp.i.i.i56, label %if.then.i.i.i59, label %if.else.i.i.i62

; CHECK: define linkonce_odr dso_local void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev(
; CHECK: call.i.i.i.i.noexc72:
; CHECK: call void @__csan_load(i64 %138, i8* bitcast (%"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4) to i8*)
; CHECK: load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64

; CHECK: if.then.i.i.i59:

if.then.i.i.i59:                                  ; preds = %call.i.i.i.i.noexc72
  %head.i.i.i57 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %2, i64 %conv.i.i.i.i53, i32 1
  %5 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head.i.i.i57 to i64*
  %6 = load i64, i64* %5, align 8, !tbaa !100
  %mid.i.i.i58 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %2, i64 %conv.i.i.i.i53, i32 2
  %7 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid.i.i.i58 to i64*
  store i64 %6, i64* %7, align 16, !tbaa !101
  br label %.noexc21

if.else.i.i.i62:                                  ; preds = %call.i.i.i.i.noexc72
  %mul.i.i.i60 = shl i64 %4, 1
  %cmp10.i.i.i61 = icmp eq i64 %3, %mul.i.i.i60
  br i1 %cmp10.i.i.i61, label %if.then11.i.i.i68, label %.noexc21

if.then11.i.i.i68:                                ; preds = %if.else.i.i.i62
  %mid14.i.i.i63 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %2, i64 %conv.i.i.i.i53, i32 2
  %8 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid14.i.i.i63, align 16, !tbaa !101
  %next.i.i.i64 = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %8, i64 0, i32 0
  %9 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next.i.i.i64, align 8, !tbaa !102
  invoke void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE4pushES3_(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"* nonnull getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 3), %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %9)
          to label %.noexc74 unwind label %lpad9

.noexc74:                                         ; preds = %if.then11.i.i.i68
  %10 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %mid17.i.i.i65 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %10, i64 %conv.i.i.i.i53, i32 2
  %11 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid17.i.i.i65, align 16, !tbaa !101
  %next18.i.i.i66 = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %11, i64 0, i32 0
  store %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* null, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next18.i.i.i66, align 8, !tbaa !102
  %12 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %sz22.i.i.i67 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %10, i64 %conv.i.i.i.i53, i32 0
  store i64 %12, i64* %sz22.i.i.i67, align 64, !tbaa !97
  br label %.noexc21

.noexc21:                                         ; preds = %.noexc74, %if.else.i.i.i62, %if.then.i.i.i59
  %13 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %head26.i.i.i69 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %13, i64 %conv.i.i.i.i53, i32 1
  %14 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i69 to i64*
  %15 = load i64, i64* %14, align 8, !tbaa !100
  %16 = getelementptr %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %1, i64 0, i32 0
  store i64 %15, i64* %16, align 8, !tbaa !102
  %17 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i69 to %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"**
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %1, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %17, align 8, !tbaa !100
  %sz33.i.i.i70 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %13, i64 %conv.i.i.i.i53, i32 0
  %18 = load i64, i64* %sz33.i.i.i70, align 64, !tbaa !97
  %inc.i.i.i71 = add i64 %18, 1
  store i64 %inc.i.i.i71, i64* %sz33.i.i.i70, align 64, !tbaa !97
  br label %.noexc10

.noexc10:                                         ; preds = %.noexc21, %det.achd.i
  reattach within %syncreg.i, label %det.cont.i

det.cont.i:                                       ; preds = %.noexc10, %if.then.i
  %L.i.i8 = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 2
  %19 = load %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %L.i.i8, align 8, !tbaa !104
  %cmp.i23 = icmp eq %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %19, null
  br i1 %cmp.i23, label %.noexc11, label %if.then.i24

if.then.i24:                                      ; preds = %det.cont.i
  tail call void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* nonnull %19) #16
  %call.i.i.i.i96 = invoke i32 @__cilkrts_get_worker_number()
          to label %call.i.i.i.i.noexc95 unwind label %lpad

call.i.i.i.i.noexc95:                             ; preds = %if.then.i24
  %conv.i.i.i.i76 = zext i32 %call.i.i.i.i96 to i64
  %20 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %sz.i.i.i77 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %20, i64 %conv.i.i.i.i76, i32 0
  %21 = load i64, i64* %sz.i.i.i77, align 64, !tbaa !97
  %22 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %add.i.i.i78 = add i64 %22, 1
  %cmp.i.i.i79 = icmp eq i64 %21, %add.i.i.i78
  br i1 %cmp.i.i.i79, label %if.then.i.i.i82, label %if.else.i.i.i85

if.then.i.i.i82:                                  ; preds = %call.i.i.i.i.noexc95
  %head.i.i.i80 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %20, i64 %conv.i.i.i.i76, i32 1
  %23 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head.i.i.i80 to i64*
  %24 = load i64, i64* %23, align 8, !tbaa !100
  %mid.i.i.i81 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %20, i64 %conv.i.i.i.i76, i32 2
  %25 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid.i.i.i81 to i64*
  store i64 %24, i64* %25, align 16, !tbaa !101
  br label %.noexc25

if.else.i.i.i85:                                  ; preds = %call.i.i.i.i.noexc95
  %mul.i.i.i83 = shl i64 %22, 1
  %cmp10.i.i.i84 = icmp eq i64 %21, %mul.i.i.i83
  br i1 %cmp10.i.i.i84, label %if.then11.i.i.i91, label %.noexc25

if.then11.i.i.i91:                                ; preds = %if.else.i.i.i85
  %mid14.i.i.i86 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %20, i64 %conv.i.i.i.i76, i32 2
  %26 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid14.i.i.i86, align 16, !tbaa !101
  %next.i.i.i87 = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %26, i64 0, i32 0
  %27 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next.i.i.i87, align 8, !tbaa !102
  invoke void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE4pushES3_(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"* nonnull getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 3), %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %27)
          to label %.noexc97 unwind label %lpad

.noexc97:                                         ; preds = %if.then11.i.i.i91
  %28 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %mid17.i.i.i88 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %28, i64 %conv.i.i.i.i76, i32 2
  %29 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid17.i.i.i88, align 16, !tbaa !101
  %next18.i.i.i89 = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %29, i64 0, i32 0
  store %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* null, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next18.i.i.i89, align 8, !tbaa !102
  %30 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %sz22.i.i.i90 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %28, i64 %conv.i.i.i.i76, i32 0
  store i64 %30, i64* %sz22.i.i.i90, align 64, !tbaa !97
  br label %.noexc25

.noexc25:                                         ; preds = %.noexc97, %if.else.i.i.i85, %if.then.i.i.i82
  %31 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %head26.i.i.i92 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %31, i64 %conv.i.i.i.i76, i32 1
  %32 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i92 to i64*
  %33 = load i64, i64* %32, align 8, !tbaa !100
  %34 = getelementptr %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %19, i64 0, i32 0
  store i64 %33, i64* %34, align 8, !tbaa !102
  %35 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i92 to %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"**
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %19, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %35, align 8, !tbaa !100
  %sz33.i.i.i93 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %31, i64 %conv.i.i.i.i76, i32 0
  %36 = load i64, i64* %sz33.i.i.i93, align 64, !tbaa !97
  %inc.i.i.i94 = add i64 %36, 1
  store i64 %inc.i.i.i94, i64* %sz33.i.i.i93, align 64, !tbaa !97
  br label %.noexc11

.noexc11:                                         ; preds = %.noexc25, %det.cont.i
  sync within %syncreg.i, label %sync.continue.i

sync.continue.i:                                  ; preds = %.noexc11
  invoke void @llvm.sync.unwind(token %syncreg.i)
          to label %invoke.cont unwind label %lpad

lpad.unreachable:                                 ; preds = %lpad9
  unreachable

lpad9:                                            ; preds = %if.then11.i.i.i68, %if.then.i20
  %37 = landingpad { i8*, i32 }
          cleanup
  invoke void @llvm.detached.rethrow.sl_p0i8i32s(token %syncreg.i, { i8*, i32 } %37)
          to label %lpad.unreachable unwind label %lpad

if.else.i:                                        ; preds = %entry
  %L.i.i = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 2
  %38 = load %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %L.i.i, align 8, !tbaa !104
  %cmp.i = icmp eq %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %38, null
  br i1 %cmp.i, label %.noexc1, label %if.then.i13

if.then.i13:                                      ; preds = %if.else.i
  tail call void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* nonnull %38) #16
  %call.i.i.i.i28 = invoke i32 @__cilkrts_get_worker_number()
          to label %call.i.i.i.i.noexc unwind label %lpad

call.i.i.i.i.noexc:                               ; preds = %if.then.i13
  %conv.i.i.i.i = zext i32 %call.i.i.i.i28 to i64
  %39 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %sz.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %39, i64 %conv.i.i.i.i, i32 0
  %40 = load i64, i64* %sz.i.i.i, align 64, !tbaa !97
  %41 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %add.i.i.i = add i64 %41, 1
  %cmp.i.i.i = icmp eq i64 %40, %add.i.i.i
  br i1 %cmp.i.i.i, label %if.then.i.i.i27, label %if.else.i.i.i

if.then.i.i.i27:                                  ; preds = %call.i.i.i.i.noexc
  %head.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %39, i64 %conv.i.i.i.i, i32 1
  %42 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head.i.i.i to i64*
  %43 = load i64, i64* %42, align 8, !tbaa !100
  %mid.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %39, i64 %conv.i.i.i.i, i32 2
  %44 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid.i.i.i to i64*
  store i64 %43, i64* %44, align 16, !tbaa !101
  br label %.noexc14

if.else.i.i.i:                                    ; preds = %call.i.i.i.i.noexc
  %mul.i.i.i = shl i64 %41, 1
  %cmp10.i.i.i = icmp eq i64 %40, %mul.i.i.i
  br i1 %cmp10.i.i.i, label %if.then11.i.i.i, label %.noexc14

if.then11.i.i.i:                                  ; preds = %if.else.i.i.i
  %mid14.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %39, i64 %conv.i.i.i.i, i32 2
  %45 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid14.i.i.i, align 16, !tbaa !101
  %next.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %45, i64 0, i32 0
  %46 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next.i.i.i, align 8, !tbaa !102
  invoke void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE4pushES3_(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"* nonnull getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 3), %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %46)
          to label %.noexc29 unwind label %lpad

.noexc29:                                         ; preds = %if.then11.i.i.i
  %47 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %mid17.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %47, i64 %conv.i.i.i.i, i32 2
  %48 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid17.i.i.i, align 16, !tbaa !101
  %next18.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %48, i64 0, i32 0
  store %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* null, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next18.i.i.i, align 8, !tbaa !102
  %49 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %sz22.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %47, i64 %conv.i.i.i.i, i32 0
  store i64 %49, i64* %sz22.i.i.i, align 64, !tbaa !97
  br label %.noexc14

.noexc14:                                         ; preds = %.noexc29, %if.else.i.i.i, %if.then.i.i.i27
  %50 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %head26.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %50, i64 %conv.i.i.i.i, i32 1
  %51 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i to i64*
  %52 = load i64, i64* %51, align 8, !tbaa !100
  %53 = getelementptr %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %38, i64 0, i32 0
  store i64 %52, i64* %53, align 8, !tbaa !102
  %54 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i to %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"**
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %38, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %54, align 8, !tbaa !100
  %sz33.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %50, i64 %conv.i.i.i.i, i32 0
  %55 = load i64, i64* %sz33.i.i.i, align 64, !tbaa !97
  %inc.i.i.i = add i64 %55, 1
  store i64 %inc.i.i.i, i64* %sz33.i.i.i, align 64, !tbaa !97
  br label %.noexc1

.noexc1:                                          ; preds = %.noexc14, %if.else.i
  %R.i.i = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 3
  %56 = load %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %R.i.i, align 8, !tbaa !88
  %cmp.i15 = icmp eq %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %56, null
  br i1 %cmp.i15, label %invoke.cont, label %if.then.i16

if.then.i16:                                      ; preds = %.noexc1
  tail call void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeD2Ev(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* nonnull %56) #16
  %call.i.i.i.i50 = invoke i32 @__cilkrts_get_worker_number()
          to label %call.i.i.i.i.noexc49 unwind label %lpad

call.i.i.i.i.noexc49:                             ; preds = %if.then.i16
  %conv.i.i.i.i30 = zext i32 %call.i.i.i.i50 to i64
  %57 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %sz.i.i.i31 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %57, i64 %conv.i.i.i.i30, i32 0
  %58 = load i64, i64* %sz.i.i.i31, align 64, !tbaa !97
  %59 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %add.i.i.i32 = add i64 %59, 1
  %cmp.i.i.i33 = icmp eq i64 %58, %add.i.i.i32
  br i1 %cmp.i.i.i33, label %if.then.i.i.i36, label %if.else.i.i.i39

if.then.i.i.i36:                                  ; preds = %call.i.i.i.i.noexc49
  %head.i.i.i34 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %57, i64 %conv.i.i.i.i30, i32 1
  %60 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head.i.i.i34 to i64*
  %61 = load i64, i64* %60, align 8, !tbaa !100
  %mid.i.i.i35 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %57, i64 %conv.i.i.i.i30, i32 2
  %62 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid.i.i.i35 to i64*
  store i64 %61, i64* %62, align 16, !tbaa !101
  br label %.noexc17

if.else.i.i.i39:                                  ; preds = %call.i.i.i.i.noexc49
  %mul.i.i.i37 = shl i64 %59, 1
  %cmp10.i.i.i38 = icmp eq i64 %58, %mul.i.i.i37
  br i1 %cmp10.i.i.i38, label %if.then11.i.i.i45, label %.noexc17

if.then11.i.i.i45:                                ; preds = %if.else.i.i.i39
  %mid14.i.i.i40 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %57, i64 %conv.i.i.i.i30, i32 2
  %63 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid14.i.i.i40, align 16, !tbaa !101
  %next.i.i.i41 = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %63, i64 0, i32 0
  %64 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next.i.i.i41, align 8, !tbaa !102
  invoke void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE4pushES3_(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"* nonnull getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 3), %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %64)
          to label %.noexc51 unwind label %lpad

.noexc51:                                         ; preds = %if.then11.i.i.i45
  %65 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %mid17.i.i.i42 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %65, i64 %conv.i.i.i.i30, i32 2
  %66 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %mid17.i.i.i42, align 16, !tbaa !101
  %next18.i.i.i43 = getelementptr inbounds %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875", %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %66, i64 0, i32 0
  store %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* null, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %next18.i.i.i43, align 8, !tbaa !102
  %67 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %sz22.i.i.i44 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %65, i64 %conv.i.i.i.i30, i32 0
  store i64 %67, i64* %sz22.i.i.i44, align 64, !tbaa !97
  br label %.noexc17

.noexc17:                                         ; preds = %.noexc51, %if.else.i.i.i39, %if.then.i.i.i36
  %68 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %head26.i.i.i46 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %68, i64 %conv.i.i.i.i30, i32 1
  %69 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i46 to i64*
  %70 = load i64, i64* %69, align 8, !tbaa !100
  %71 = getelementptr %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %56, i64 0, i32 0
  store i64 %70, i64* %71, align 8, !tbaa !102
  %72 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head26.i.i.i46 to %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"**
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %56, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %72, align 8, !tbaa !100
  %sz33.i.i.i47 = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %68, i64 %conv.i.i.i.i30, i32 0
  %73 = load i64, i64* %sz33.i.i.i47, align 64, !tbaa !97
  %inc.i.i.i48 = add i64 %73, 1
  store i64 %inc.i.i.i48, i64* %sz33.i.i.i47, align 64, !tbaa !97
  br label %invoke.cont

invoke.cont:                                      ; preds = %.noexc17, %.noexc1, %sync.continue.i
  %flag.i.i.i.i = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 6, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i = load i8, i8* %flag.i.i.i.i, align 1
  %cmp.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i, -1
  br i1 %cmp.i.i.i.i, label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %invoke.cont
  %buffer.i.i.i.i = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 6, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %74 = load %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i, align 1, !tbaa !2
  %capacity.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947", %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %74, i64 0, i32 0
  %75 = load i64, i64* %capacity.i.i.i.i.i, align 8, !tbaa !7
  %call.i.i.i.i.i1.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i:                         ; preds = %if.then.i.i.i
  %76 = bitcast %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* %74 to i8*
  %mul.i.i.i.i.i = shl i64 %75, 3
  %add.i.i.i.i.i = add i64 %mul.i.i.i.i.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i, i8* %76, i64 %add.i.i.i.i.i)
          to label %.noexc.i.i unwind label %lpad.i.i

.noexc.i.i:                                       ; preds = %call.i.i.i.i.i.noexc.i.i
  store %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"* null, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl::capacitated_buffer::header.101.412.719.1026.1333.1640.1947"** %buffer.i.i.i.i, align 1, !tbaa !2
  br label %_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit

lpad.i.i:                                         ; preds = %call.i.i.i.i.i.noexc.i.i, %if.then.i.i.i
  %77 = landingpad { i8*, i32 }
          catch i8* null
  %78 = extractvalue { i8*, i32 } %77, 0
  tail call void @__clang_call_terminate(i8* %78) #17
  unreachable

_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev.exit: ; preds = %.noexc.i.i, %invoke.cont
  store i8 0, i8* %flag.i.i.i.i, align 1
  ret void

lpad:                                             ; preds = %if.then11.i.i.i45, %if.then.i16, %if.then11.i.i.i, %if.then.i13, %lpad9, %sync.continue.i, %if.then11.i.i.i91, %if.then.i24, %if.then.i
  %79 = landingpad { i8*, i32 }
          catch i8* null
  %80 = extractvalue { i8*, i32 } %79, 0
  %81 = getelementptr inbounds %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956", %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %this, i64 0, i32 6, i32 0
  tail call void @_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEED2Ev(%"struct.parlay::_sequence_base.29.107.418.725.1032.1339.1646.1953"* nonnull %81) #16
  tail call void @__clang_call_terminate(i8* %80) #17
  unreachable
}

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZNSt10unique_ptrIN8oct_treeI6vertexI7point2dIdEEE4nodeENS5_11delete_treeEED2Ev(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"*) unnamed_addr #8 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal4packINS_5sliceIPP6vertexI7point2dIdEES8_EENS2_IPbSA_EEEENS_8sequenceINT_10value_typeENS_9allocatorISE_EEEERKSD_RKT0_j(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* noalias sret, %"struct.parlay::slice.170.480.787.1094.1401.1708.2015"* dereferenceable(16), %"struct.parlay::slice.54.171.481.788.1095.1402.1709.2016"* dereferenceable(16), i32) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_4packINS_5sliceIPP6vertexI7point2dIdEESA_EENS4_IPbSC_EEEENS_8sequenceINT_10value_typeENS_9allocatorISG_EEEERKSF_RKT0_jEUlmmmE_EEvmmSL_jEUlmE_EEvmmSF_mb(i64, i64, %class.anon.126.173.483.790.1097.1404.1711.2018* byval(%class.anon.126.173.483.790.1097.1404.1711.2018) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local i64 @_ZN6parlay8internal5scan_INS_5sliceIPmS3_EES4_NS_4addmImEEEENT_10value_typeERKS7_T0_RKT1_jb(%"struct.parlay::slice.124.174.484.791.1098.1405.1712.2019"* dereferenceable(16), i64*, i64*, %"struct.parlay::addm.154.465.772.1079.1386.1693.2000"* dereferenceable(8), i32, i1 zeroext) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPmS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE_EEvmmSC_jEUlmE_EEvmmS9_mb(i64, i64, %class.anon.129.176.486.793.1100.1407.1714.2021* byval(%class.anon.129.176.486.793.1100.1407.1714.2021) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPmS5_EES6_NS_4addmImEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE0_EEvmmSC_jEUlmE_EEvmmS9_mb(i64, i64, %class.anon.130.178.488.795.1102.1409.1716.2023* byval(%class.anon.130.178.488.795.1102.1409.1716.2023) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEC2EmNS8_18_uninitialized_tagE(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_4packINS_5sliceIPP6vertexI7point2dIdEESA_EENS4_IPbSC_EEEENS_8sequenceINT_10value_typeENS_9allocatorISG_EEEERKSF_RKT0_jEUlmmmE0_EEvmmSL_jEUlmE_EEvmmSF_mb(i64, i64, %class.anon.131.180.490.797.1104.1411.1718.2025* byval(%class.anon.131.180.490.797.1104.1411.1718.2025) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: nofree nounwind
declare dso_local i32 @gettimeofday(%struct.timeval.181.491.798.1105.1412.1719.2026* nocapture, i8* nocapture) local_unnamed_addr #7

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN5timer6reportEdNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.timer.5.316.623.930.1237.1544.1851*, double, %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"*) local_unnamed_addr #4 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZSt16__ostream_insertIcSt11char_traitsIcEERSt13basic_ostreamIT_T0_ES6_PKS3_l(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* dereferenceable(272), i8*, i64) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZNSo9_M_insertIdEERSoT_(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"*, double) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZNSo9_M_insertImEERSoT_(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"*, i64) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZNSo3putEc(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"*, i8 signext) local_unnamed_addr #0

declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZNSo5flushEv(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"*) local_unnamed_addr #0

; Function Attrs: noreturn
declare dso_local void @_ZSt16__throw_bad_castv() local_unnamed_addr #9

declare dso_local void @_ZNKSt5ctypeIcE13_M_widen_initEv(%"class.std::ctype.16.327.634.941.1248.1555.1862"*) local_unnamed_addr #0

; Function Attrs: noreturn nounwind
declare dso_local void @abort() local_unnamed_addr #15

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZNSt6vectorI7simplexI7point2dIdEESaIS3_EE17_M_realloc_insertIJRKS3_EEEvN9__gnu_cxx17__normal_iteratorIPS3_S5_EEDpOT_(%"class.std::vector.3.62.373.680.987.1294.1601.1908"*, %struct.simplex.58.369.676.983.1290.1597.1904*, %struct.simplex.58.369.676.983.1290.1597.1904* dereferenceable(16)) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZNSt6vectorIP6vertexI7point2dIdEESaIS4_EE17_M_realloc_insertIJS4_EEEvN9__gnu_cxx17__normal_iteratorIPS4_S6_EEDpOT_(%"class.std::vector.57.368.675.982.1289.1596.1903"*, %struct.vertex.52.363.670.977.1284.1591.1898**, %struct.vertex.52.363.670.977.1284.1591.1898** dereferenceable(8)) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEE15initialize_fillEmRKmEUlmE_EEvmmT_mb(i64, i64, %class.anon.137.182.492.799.1106.1413.1720.2027* byval(%class.anon.137.182.492.799.1106.1413.1720.2027) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN7simplexI7point2dIdEE5printEv(%struct.simplex.58.369.676.983.1290.1597.1904*) local_unnamed_addr #4 align 2

declare dso_local dereferenceable(272) %"class.std::basic_ostream.20.331.638.945.1252.1559.1866"* @_ZNSolsEi(%"class.std::basic_ostream.20.331.638.945.1252.1559.1866"*, i32) local_unnamed_addr #0

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEm(%"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEE18initialize_defaultEmEUlmE_EEvmmT_mb(i64, i64, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"*, %struct.vertex.52.363.670.977.1284.1591.1898***, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceIbNS_9allocatorIbEEE18initialize_defaultEm(%"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIbNS_9allocatorIbEEE18initialize_defaultEmEUlmE_EEvmmT_mb(i64, i64, %"class.parlay::sequence.38.191.501.808.1115.1422.1729.2036"*, i8**, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN8oct_treeI6vertexI7point2dIdEEE5buildIN6parlay8sequenceIPS3_NS6_9allocatorIS8_EEEEEESt10unique_ptrINS4_4nodeENS4_11delete_treeEERT_(%"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* noalias sret %agg.result, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* dereferenceable(15) %P) local_unnamed_addr #4 comdat align 2 personality i8* bitcast (i32 (...)* @__gxx_personality_v0 to i8*) {
_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit:
  %t = alloca %struct.timer.5.316.623.930.1237.1544.1851, align 8
  %agg.tmp = alloca %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", align 8
  %pts = alloca %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045", align 8
  %agg.tmp10 = alloca %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", align 8
  %agg.tmp25 = alloca %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", align 8
  %0 = bitcast %struct.timer.5.316.623.930.1237.1544.1851* %t to i8*
  call void @llvm.lifetime.start.p0i8(i64 64, i8* nonnull %0) #16
  %1 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp, i64 0, i32 2
  %2 = bitcast %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp to %union.anon.2.313.620.927.1234.1541.1848**
  store %union.anon.2.313.620.927.1234.1541.1848* %1, %union.anon.2.313.620.927.1234.1541.1848** %2, align 8, !tbaa !105
  %.cast = getelementptr %union.anon.2.313.620.927.1234.1541.1848, %union.anon.2.313.620.927.1234.1541.1848* %1, i64 0, i32 0
  store i64 7306371814621733743, i64* %.cast, align 8
  %_M_string_length.i.i.i.i.i.i = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp, i64 0, i32 1
  store i64 8, i64* %_M_string_length.i.i.i.i.i.i, align 8, !tbaa !107
  %3 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp, i64 0, i32 2, i32 1, i64 0
  store i8 0, i8* %3, align 8, !tbaa !109
  %total_time.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 0
  store double 0.000000e+00, double* %total_time.i, align 8, !tbaa !110
  %on.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 2
  store i8 0, i8* %on.i, align 8, !tbaa !113
  %name2.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 3
  %4 = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 3, i32 2
  %5 = bitcast %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %name2.i to %union.anon.2.313.620.927.1234.1541.1848**
  store %union.anon.2.313.620.927.1234.1541.1848* %4, %union.anon.2.313.620.927.1234.1541.1848** %5, align 8, !tbaa !105
  %6 = bitcast %union.anon.2.313.620.927.1234.1541.1848* %4 to i8*
  %7 = getelementptr %union.anon.2.313.620.927.1234.1541.1848, %union.anon.2.313.620.927.1234.1541.1848* %4, i64 0, i32 0
  store i64 7306371814621733743, i64* %7, align 8
  %_M_string_length.i.i.i.i.i.i.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 3, i32 1
  store i64 8, i64* %_M_string_length.i.i.i.i.i.i.i, align 8, !tbaa !107
  %8 = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 3, i32 2, i32 1, i64 0
  store i8 0, i8* %8, align 8, !tbaa !109
  %tz_minuteswest.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 4, i32 0
  store i32 0, i32* %tz_minuteswest.i, align 8, !tbaa !114
  %tz_dsttime.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 4, i32 1
  store i32 0, i32* %tz_dsttime.i, align 4, !tbaa !115
  %9 = bitcast %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts to i8*
  call void @llvm.lifetime.start.p0i8(i64 15, i8* nonnull %9) #16
  invoke void @_ZN8oct_treeI6vertexI7point2dIdEEE10tag_pointsERN6parlay8sequenceIPS3_NS5_9allocatorIS7_EEEE(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* nonnull sret %pts, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* nonnull dereferenceable(15) %P)
          to label %invoke.cont9 unwind label %lpad8

invoke.cont9:                                     ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %10 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp10, i64 0, i32 2
  %11 = bitcast %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp10 to %union.anon.2.313.620.927.1234.1541.1848**
  store %union.anon.2.313.620.927.1234.1541.1848* %10, %union.anon.2.313.620.927.1234.1541.1848** %11, align 8, !tbaa !105
  %_M_p.i.i.i.i.i22 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp10, i64 0, i32 0, i32 0
  %.cast91 = bitcast %union.anon.2.313.620.927.1234.1541.1848* %10 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(3) %.cast91, i8* nonnull align 1 dereferenceable(3) getelementptr inbounds ([4 x i8], [4 x i8]* @.str.29, i64 0, i64 0), i64 3, i1 false) #16
  %_M_string_length.i.i.i.i.i.i26 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp10, i64 0, i32 1
  store i64 3, i64* %_M_string_length.i.i.i.i.i.i26, align 8, !tbaa !107
  %arrayidx.i.i.i.i.i27 = getelementptr inbounds i8, i8* %.cast91, i64 3
  store i8 0, i8* %arrayidx.i.i.i.i.i27, align 1, !tbaa !109
  invoke void @_ZN5timer4nextENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.timer.5.316.623.930.1237.1544.1851* nonnull %t, %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* nonnull %agg.tmp10)
          to label %invoke.cont15 unwind label %lpad14

invoke.cont15:                                    ; preds = %invoke.cont9
  %12 = load i8*, i8** %_M_p.i.i.i.i.i22, align 8, !tbaa !116
  %cmp.i.i.i33 = icmp eq i8* %12, %.cast91
  br i1 %cmp.i.i.i33, label %invoke.cont21, label %if.then.i.i34

if.then.i.i34:                                    ; preds = %invoke.cont15
  call void @_ZdlPv(i8* %12) #16
  br label %invoke.cont21

invoke.cont21:                                    ; preds = %if.then.i.i34, %invoke.cont15
  %flag.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045", %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i = load i8, i8* %flag.i.i.i.i.i, align 2
  %cmp.i.i.i.i.i36 = icmp sgt i8 %bf.load.i.i.i.i.i, -1
  %13 = bitcast %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts to %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*
  %buffer.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045", %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %14 = load %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"*, %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"** %buffer.i.i.i.i.i.i, align 8
  %data.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038", %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* %14, i64 0, i32 1, i32 0
  %15 = bitcast [1 x i8]* %data.i.i.i.i.i.i.i to %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*
  %retval.0.i.i.i.i = select i1 %cmp.i.i.i.i.i36, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %13, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %15
  %conv.i.i.i.i = zext i8 %bf.load.i.i.i.i.i to i64
  %n.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045", %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 1
  %16 = bitcast [6 x i8]* %n.i.i.i.i.i to i48*
  %bf.load.i1.i.i.i.i = load i48, i48* %16, align 8
  %bf.cast.i.i.i.i.i = zext i48 %bf.load.i1.i.i.i.i to i64
  %retval.0.i6.i.i.i = select i1 %cmp.i.i.i.i.i36, i64 %conv.i.i.i.i, i64 %bf.cast.i.i.i.i.i
  %add.ptr.i.i.i = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %retval.0.i.i.i.i, i64 %retval.0.i6.i.i.i
  %call24 = invoke %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* nonnull %retval.0.i.i.i.i, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* nonnull %add.ptr.i.i.i, i32 64)
          to label %invoke.cont23 unwind label %lpad20

invoke.cont23:                                    ; preds = %invoke.cont21
  %17 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp25, i64 0, i32 2
  %18 = bitcast %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp25 to %union.anon.2.313.620.927.1234.1541.1848**
  store %union.anon.2.313.620.927.1234.1541.1848* %17, %union.anon.2.313.620.927.1234.1541.1848** %18, align 8, !tbaa !105
  %_M_p.i.i.i.i.i48 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp25, i64 0, i32 0, i32 0
  %.cast93 = bitcast %union.anon.2.313.620.927.1234.1541.1848* %17 to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(5) %.cast93, i8* nonnull align 1 dereferenceable(5) getelementptr inbounds ([6 x i8], [6 x i8]* @.str.30, i64 0, i64 0), i64 5, i1 false) #16
  %_M_string_length.i.i.i.i.i.i52 = getelementptr inbounds %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849", %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* %agg.tmp25, i64 0, i32 1
  store i64 5, i64* %_M_string_length.i.i.i.i.i.i52, align 8, !tbaa !107
  %arrayidx.i.i.i.i.i53 = getelementptr inbounds i8, i8* %.cast93, i64 5
  store i8 0, i8* %arrayidx.i.i.i.i.i53, align 1, !tbaa !109
  invoke void @_ZN5timer4nextENSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE(%struct.timer.5.316.623.930.1237.1544.1851* nonnull %t, %"class.std::__cxx11::basic_string.3.314.621.928.1235.1542.1849"* nonnull %agg.tmp25)
          to label %invoke.cont30 unwind label %lpad29

invoke.cont30:                                    ; preds = %invoke.cont23
  %19 = load i8*, i8** %_M_p.i.i.i.i.i48, align 8, !tbaa !116
  %cmp.i.i.i59 = icmp eq i8* %19, %.cast93
  br i1 %cmp.i.i.i59, label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit61, label %if.then.i.i60

if.then.i.i60:                                    ; preds = %invoke.cont30
  call void @_ZdlPv(i8* %19) #16
  br label %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit61

_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit61: ; preds = %if.then.i.i60, %invoke.cont30
  %_M_head_impl.i.i.i.i.i.i.i.i = getelementptr inbounds %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962", %"class.std::unique_ptr.116.427.734.1041.1348.1655.1962"* %agg.result, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %call24, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %_M_head_impl.i.i.i.i.i.i.i.i, align 8, !tbaa !13
  %bf.load.i.i.i.i68 = load i8, i8* %flag.i.i.i.i.i, align 2
  %cmp.i.i.i.i69 = icmp sgt i8 %bf.load.i.i.i.i68, -1
  br i1 %cmp.i.i.i.i69, label %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit79, label %if.then.i.i.i73

if.then.i.i.i73:                                  ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit61
  %20 = load %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"*, %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"** %buffer.i.i.i.i.i.i, align 8, !tbaa !117
  %capacity.i.i.i.i.i71 = getelementptr inbounds %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038", %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* %20, i64 0, i32 0
  %21 = load i64, i64* %capacity.i.i.i.i.i71, align 8, !tbaa !119
  %call.i.i.i.i.i1.i.i72 = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i76 unwind label %lpad.i.i78

call.i.i.i.i.i.noexc.i.i76:                       ; preds = %if.then.i.i.i73
  %22 = bitcast %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* %20 to i8*
  %mul.i.i.i.i.i74 = shl i64 %21, 4
  %add.i.i.i.i.i75 = or i64 %mul.i.i.i.i.i74, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i72, i8* %22, i64 %add.i.i.i.i.i75)
          to label %.noexc.i.i77 unwind label %lpad.i.i78

.noexc.i.i77:                                     ; preds = %call.i.i.i.i.i.noexc.i.i76
  store %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* null, %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"** %buffer.i.i.i.i.i.i, align 8, !tbaa !117
  br label %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit79

lpad.i.i78:                                       ; preds = %call.i.i.i.i.i.noexc.i.i76, %if.then.i.i.i73
  %23 = landingpad { i8*, i32 }
          catch i8* null
  %24 = extractvalue { i8*, i32 } %23, 0
  call void @__clang_call_terminate(i8* %24) #17
  unreachable

_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit79: ; preds = %.noexc.i.i77, %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit61
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %9) #16
  %_M_p.i.i.i.i.i80 = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 3, i32 0, i32 0
  %25 = load i8*, i8** %_M_p.i.i.i.i.i80, align 8, !tbaa !116
  %cmp.i.i.i.i82 = icmp eq i8* %25, %6
  br i1 %cmp.i.i.i.i82, label %_ZN5timerD2Ev.exit84, label %if.then.i.i.i83

if.then.i.i.i83:                                  ; preds = %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit79
  call void @_ZdlPv(i8* %25) #16
  br label %_ZN5timerD2Ev.exit84

_ZN5timerD2Ev.exit84:                             ; preds = %if.then.i.i.i83, %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit79
  call void @llvm.lifetime.end.p0i8(i64 64, i8* nonnull %0) #16
  ret void

lpad8:                                            ; preds = %_ZNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEED2Ev.exit
  %26 = landingpad { i8*, i32 }
          cleanup
  %27 = extractvalue { i8*, i32 } %26, 0
  %28 = extractvalue { i8*, i32 } %26, 1
  br label %ehcleanup36

lpad14:                                           ; preds = %invoke.cont9
  %29 = landingpad { i8*, i32 }
          cleanup
  %30 = extractvalue { i8*, i32 } %29, 0
  %31 = extractvalue { i8*, i32 } %29, 1
  %32 = load i8*, i8** %_M_p.i.i.i.i.i22, align 8, !tbaa !116
  %cmp.i.i.i64 = icmp eq i8* %32, %.cast91
  br i1 %cmp.i.i.i64, label %ehcleanup35, label %if.then.i.i65

if.then.i.i65:                                    ; preds = %lpad14
  call void @_ZdlPv(i8* %32) #16
  br label %ehcleanup35

lpad20:                                           ; preds = %invoke.cont21
  %33 = landingpad { i8*, i32 }
          cleanup
  %34 = extractvalue { i8*, i32 } %33, 0
  %35 = extractvalue { i8*, i32 } %33, 1
  br label %ehcleanup35

lpad29:                                           ; preds = %invoke.cont23
  %36 = landingpad { i8*, i32 }
          cleanup
  %37 = extractvalue { i8*, i32 } %36, 0
  %38 = extractvalue { i8*, i32 } %36, 1
  %39 = load i8*, i8** %_M_p.i.i.i.i.i48, align 8, !tbaa !116
  %cmp.i.i.i39 = icmp eq i8* %39, %.cast93
  br i1 %cmp.i.i.i39, label %ehcleanup35, label %if.then.i.i40

if.then.i.i40:                                    ; preds = %lpad29
  call void @_ZdlPv(i8* %39) #16
  br label %ehcleanup35

ehcleanup35:                                      ; preds = %if.then.i.i40, %lpad29, %lpad20, %if.then.i.i65, %lpad14
  %ehselector.slot.4 = phi i32 [ %35, %lpad20 ], [ %31, %lpad14 ], [ %31, %if.then.i.i65 ], [ %38, %lpad29 ], [ %38, %if.then.i.i40 ]
  %exn.slot.4 = phi i8* [ %34, %lpad20 ], [ %30, %lpad14 ], [ %30, %if.then.i.i65 ], [ %37, %lpad29 ], [ %37, %if.then.i.i40 ]
  %flag.i.i.i.i12 = getelementptr inbounds %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045", %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i13 = load i8, i8* %flag.i.i.i.i12, align 2
  %cmp.i.i.i.i14 = icmp sgt i8 %bf.load.i.i.i.i13, -1
  br i1 %cmp.i.i.i.i14, label %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit, label %if.then.i.i.i15

if.then.i.i.i15:                                  ; preds = %ehcleanup35
  %buffer.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045", %"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* %pts, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %40 = load %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"*, %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"** %buffer.i.i.i.i, align 8, !tbaa !117
  %capacity.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038", %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* %40, i64 0, i32 0
  %41 = load i64, i64* %capacity.i.i.i.i.i, align 8, !tbaa !119
  %call.i.i.i.i.i1.i.i = invoke dereferenceable(96) %"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* @_ZN6parlay8internal21get_default_allocatorEv()
          to label %call.i.i.i.i.i.noexc.i.i unwind label %lpad.i.i

call.i.i.i.i.i.noexc.i.i:                         ; preds = %if.then.i.i.i15
  %42 = bitcast %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* %40 to i8*
  %mul.i.i.i.i.i = shl i64 %41, 4
  %add.i.i.i.i.i = or i64 %mul.i.i.i.i.i, 8
  invoke void @_ZN6parlay14pool_allocator10deallocateEPvm(%"struct.parlay::pool_allocator.50.361.668.975.1282.1589.1896"* nonnull %call.i.i.i.i.i1.i.i, i8* %42, i64 %add.i.i.i.i.i)
          to label %.noexc.i.i unwind label %lpad.i.i

.noexc.i.i:                                       ; preds = %call.i.i.i.i.i.noexc.i.i
  store %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"* null, %"struct.parlay::_sequence_base<std::pair<unsigned long, vertex<point2d<double> > *>, parlay::allocator<std::pair<unsigned long, vertex<point2d<double> > *> > >::_sequence_impl::capacitated_buffer::header.194.503.810.1117.1424.1731.2038"** %buffer.i.i.i.i, align 8, !tbaa !117
  br label %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit

lpad.i.i:                                         ; preds = %call.i.i.i.i.i.noexc.i.i, %if.then.i.i.i15
  %43 = landingpad { i8*, i32 }
          catch i8* null
  %44 = extractvalue { i8*, i32 } %43, 0
  call void @__clang_call_terminate(i8* %44) #17
  unreachable

_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit: ; preds = %.noexc.i.i, %ehcleanup35
  store i8 0, i8* %flag.i.i.i.i12, align 2
  br label %ehcleanup36

ehcleanup36:                                      ; preds = %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit, %lpad8
  %ehselector.slot.5 = phi i32 [ %ehselector.slot.4, %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit ], [ %28, %lpad8 ]
  %exn.slot.5 = phi i8* [ %exn.slot.4, %_ZN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEED2Ev.exit ], [ %27, %lpad8 ]
  call void @llvm.lifetime.end.p0i8(i64 15, i8* nonnull %9) #16
  %_M_p.i.i.i.i.i = getelementptr inbounds %struct.timer.5.316.623.930.1237.1544.1851, %struct.timer.5.316.623.930.1237.1544.1851* %t, i64 0, i32 3, i32 0, i32 0
  %45 = load i8*, i8** %_M_p.i.i.i.i.i, align 8, !tbaa !116
  %cmp.i.i.i.i = icmp eq i8* %45, %6
  br i1 %cmp.i.i.i.i, label %ehcleanup39, label %if.then.i.i.i

if.then.i.i.i:                                    ; preds = %ehcleanup36
  call void @_ZdlPv(i8* %45) #16
  br label %ehcleanup39

ehcleanup39:                                      ; preds = %if.then.i.i.i, %ehcleanup36
  call void @llvm.lifetime.end.p0i8(i64 64, i8* nonnull %0) #16
  %lpad.val = insertvalue { i8*, i32 } undef, i8* %exn.slot.5, 0
  %lpad.val40 = insertvalue { i8*, i32 } %lpad.val, i32 %ehselector.slot.5, 1
  resume { i8*, i32 } %lpad.val40
}

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN8oct_treeI6vertexI7point2dIdEEE10tag_pointsERN6parlay8sequenceIPS3_NS5_9allocatorIS7_EEEE(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* noalias sret, %"class.parlay::sequence.28.108.419.726.1033.1340.1647.1954"* dereferenceable(15)) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
define linkonce_odr dso_local %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce1, i32 %bit) local_unnamed_addr #4 comdat align 2 {
entry:
  %syncreg.i.i = tail call token @llvm.syncregion.start()
  %R = alloca %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, align 8
  %0 = ptrtoint %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0 to i64
  %1 = ptrtoint %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce1 to i64
  %sub.ptr.sub.i = sub i64 %1, %0
  %sub.ptr.div.i = ashr exact i64 %sub.ptr.sub.i, 4
  %cmp = icmp eq i64 %sub.ptr.sub.i, 0
  br i1 %cmp, label %if.then, label %if.end

if.then:                                          ; preds = %entry
  tail call void @abort() #17
  unreachable

if.end:                                           ; preds = %entry
  %cmp1 = icmp eq i32 %bit, 0
  %cmp2 = icmp ult i64 %sub.ptr.div.i, 20
  %or.cond = or i1 %cmp1, %cmp2
  br i1 %or.cond, label %if.then3, label %while.body.lr.ph.i

if.then3:                                         ; preds = %if.end
  %call.i.i.i.i.i = tail call i32 @__cilkrts_get_worker_number()
  %conv.i.i.i.i.i = zext i32 %call.i.i.i.i.i to i64
  %2 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %sz.i.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %2, i64 %conv.i.i.i.i.i, i32 0
  %3 = load i64, i64* %sz.i.i.i.i, align 64, !tbaa !97
  %cmp.i.i.i.i = icmp eq i64 %3, 0
  br i1 %cmp.i.i.i.i, label %if.then.i.i.i.i, label %_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_leafEN6parlay5sliceIPSt4pairImPS3_ESB_EE.exit

if.then.i.i.i.i:                                  ; preds = %if.then3
  %call2.i.i.i.i = tail call %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* @_ZN6parlay15block_allocator8get_listEv(%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* nonnull @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE)
  %4 = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %head.i.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %4, i64 %conv.i.i.i.i.i, i32 1
  store %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %call2.i.i.i.i, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head.i.i.i.i, align 8, !tbaa !100
  %5 = load i64, i64* getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 5), align 8, !tbaa !99
  %sz7.i.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %4, i64 %conv.i.i.i.i.i, i32 0
  store i64 %5, i64* %sz7.i.i.i.i, align 64, !tbaa !97
  %.pre = load %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"*, %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"** getelementptr inbounds (%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882", %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"* @_ZN6parlay14type_allocatorIN8oct_treeI6vertexI7point2dIdEEE4nodeEE9allocatorE, i64 0, i32 4), align 64, !tbaa !89
  %sz10.i.i.i.i.phi.trans.insert = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %.pre, i64 %conv.i.i.i.i.i, i32 0
  %.pre1 = load i64, i64* %sz10.i.i.i.i.phi.trans.insert, align 64, !tbaa !97
  br label %_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_leafEN6parlay5sliceIPSt4pairImPS3_ESB_EE.exit

_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_leafEN6parlay5sliceIPSt4pairImPS3_ESB_EE.exit: ; preds = %if.then.i.i.i.i, %if.then3
  %6 = phi i64 [ %3, %if.then3 ], [ %.pre1, %if.then.i.i.i.i ]
  %7 = phi %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* [ %2, %if.then3 ], [ %.pre, %if.then.i.i.i.i ]
  %sz10.i.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %7, i64 %conv.i.i.i.i.i, i32 0
  %dec.i.i.i.i = add i64 %6, -1
  store i64 %dec.i.i.i.i, i64* %sz10.i.i.i.i, align 64, !tbaa !97
  %head13.i.i.i.i = getelementptr inbounds %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879", %"struct.parlay::block_allocator::thread_list.33.344.651.958.1265.1572.1879"* %7, i64 %conv.i.i.i.i.i, i32 1
  %8 = load %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"*, %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head13.i.i.i.i, align 8, !tbaa !100
  %9 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %8 to i64*
  %10 = load i64, i64* %9, align 8, !tbaa !102
  %11 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"** %head13.i.i.i.i to i64*
  store i64 %10, i64* %11, align 8, !tbaa !100
  %12 = bitcast %"struct.parlay::block_allocator::block.29.340.647.954.1261.1568.1875"* %8 to %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*
  tail call void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeC2EN6parlay5sliceIPSt4pairImPS3_ESB_EE(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %12, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce1)
  br label %cleanup24

while.body.lr.ph.i:                               ; preds = %if.end
  %sub = add nsw i32 %bit, -1
  %sh_prom = zext i32 %sub to i64
  %shl = shl nuw i64 1, %sh_prom
  %cmp5 = icmp eq i32 %bit, 64
  %sh_prom6 = zext i32 %bit to i64
  %shl7 = shl nsw i64 -1, %sh_prom6
  %neg = xor i64 %shl7, -1
  %cond = select i1 %cmp5, i64 -1, i64 %neg
  br label %while.body.i

while.body.i:                                     ; preds = %while.body.i, %while.body.lr.ph.i
  %start.027.i = phi i64 [ 0, %while.body.lr.ph.i ], [ %start.1.i, %while.body.i ]
  %end.026.i = phi i64 [ %sub.ptr.div.i, %while.body.lr.ph.i ], [ %end.1.i, %while.body.i ]
  %add.i = add i64 %end.026.i, %start.027.i
  %div.i = lshr i64 %add.i, 1
  %agg.tmp.sroa.0.0..sroa_idx.i = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, i64 %div.i, i32 0
  %agg.tmp.sroa.0.0.copyload.i = load i64, i64* %agg.tmp.sroa.0.0..sroa_idx.i, align 8
  %and.i.i = and i64 %agg.tmp.sroa.0.0.copyload.i, %cond
  %cmp.i16.i = icmp ult i64 %and.i.i, %shl
  %add3.i = add nuw i64 %div.i, 1
  %end.1.i = select i1 %cmp.i16.i, i64 %end.026.i, i64 %div.i
  %start.1.i = select i1 %cmp.i16.i, i64 %add3.i, i64 %start.027.i
  %sub.i = sub i64 %end.1.i, %start.1.i
  %cmp.i = icmp ugt i64 %sub.i, 16
  br i1 %cmp.i, label %while.body.i, label %while.end.i

while.end.i:                                      ; preds = %while.body.i
  %add.ptr.i.i = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, i64 %start.1.i
  %add.ptr3.i.i = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, i64 %end.1.i
  %13 = ptrtoint %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr.i.i to i64
  %14 = ptrtoint %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr3.i.i to i64
  %sub.ptr.sub.i11.i.i = sub i64 %14, %13
  %sub.ptr.div.i12.i.i = ashr exact i64 %sub.ptr.sub.i11.i.i, 4
  %cmp13.i.i = icmp eq i64 %sub.ptr.sub.i11.i.i, 0
  br i1 %cmp13.i.i, label %_ZN6parlay8internal13binary_searchINS_5sliceIPSt4pairImP6vertexI7point2dIdEEESA_EEZN8oct_treeIS7_E15build_recursiveESB_iEUlS9_E_EEmRKT_RKT0_.exit, label %for.body.i.i

for.body.i.i:                                     ; preds = %for.inc.i.i, %while.end.i
  %i.014.i.i = phi i64 [ %inc.i.i, %for.inc.i.i ], [ 0, %while.end.i ]
  %agg.tmp.sroa.0.0..sroa_idx.i.i = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr.i.i, i64 %i.014.i.i, i32 0
  %agg.tmp.sroa.0.0.copyload.i.i = load i64, i64* %agg.tmp.sroa.0.0..sroa_idx.i.i, align 8
  %and.i.i.i = and i64 %agg.tmp.sroa.0.0.copyload.i.i, %cond
  %cmp.i.i.i = icmp ult i64 %and.i.i.i, %shl
  br i1 %cmp.i.i.i, label %for.inc.i.i, label %_ZN6parlay8internal13binary_searchINS_5sliceIPSt4pairImP6vertexI7point2dIdEEESA_EEZN8oct_treeIS7_E15build_recursiveESB_iEUlS9_E_EEmRKT_RKT0_.exit

for.inc.i.i:                                      ; preds = %for.body.i.i
  %inc.i.i = add nuw i64 %i.014.i.i, 1
  %cmp.i.i = icmp ult i64 %inc.i.i, %sub.ptr.div.i12.i.i
  br i1 %cmp.i.i, label %for.body.i.i, label %_ZN6parlay8internal13binary_searchINS_5sliceIPSt4pairImP6vertexI7point2dIdEEESA_EEZN8oct_treeIS7_E15build_recursiveESB_iEUlS9_E_EEmRKT_RKT0_.exit

_ZN6parlay8internal13binary_searchINS_5sliceIPSt4pairImP6vertexI7point2dIdEEESA_EEZN8oct_treeIS7_E15build_recursiveESB_iEUlS9_E_EEmRKT_RKT0_.exit: ; preds = %for.inc.i.i, %for.body.i.i, %while.end.i
  %retval.1.i.i = phi i64 [ 0, %while.end.i ], [ %i.014.i.i, %for.body.i.i ], [ %sub.ptr.div.i12.i.i, %for.inc.i.i ]
  %add8.i = add i64 %retval.1.i.i, %start.1.i
  %cmp9 = icmp eq i64 %add8.i, 0
  %cmp11 = icmp eq i64 %add8.i, %sub.ptr.div.i
  %or.cond4 = or i1 %cmp9, %cmp11
  br i1 %or.cond4, label %if.then12, label %if.else16

if.then12:                                        ; preds = %_ZN6parlay8internal13binary_searchINS_5sliceIPSt4pairImP6vertexI7point2dIdEEESA_EEZN8oct_treeIS7_E15build_recursiveESB_iEUlS9_E_EEmRKT_RKT0_.exit
  %call15 = tail call %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce1, i32 %sub)
  br label %cleanup24

if.else16:                                        ; preds = %_ZN6parlay8internal13binary_searchINS_5sliceIPSt4pairImP6vertexI7point2dIdEEESA_EEZN8oct_treeIS7_E15build_recursiveESB_iEUlS9_E_EEmRKT_RKT0_.exit
  %R.0..sroa_cast = bitcast %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %R to i8*
  call void @llvm.lifetime.start.p0i8(i64 8, i8* nonnull %R.0..sroa_cast)
  %cmp17 = icmp ugt i64 %sub.ptr.div.i, 1000
  br i1 %cmp17, label %if.then.i, label %if.else.i

if.then.i:                                        ; preds = %if.else16
  detach within %syncreg.i.i, label %det.achd.i.i, label %det.cont.i.i

det.achd.i.i:                                     ; preds = %if.then.i
  %add.ptr.i.i10 = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, i64 %add8.i
  %call2.i15 = tail call %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr.i.i10, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce1, i32 %sub)
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %call2.i15, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %R, align 8, !tbaa !13
  reattach within %syncreg.i.i, label %det.cont.i.i

det.cont.i.i:                                     ; preds = %det.achd.i.i, %if.then.i
  %add.ptr3.i.i7 = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, i64 %add8.i
  %call2.i = tail call %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr3.i.i7, i32 %sub)
  sync within %syncreg.i.i, label %_ZN6parlay6par_doIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvT_T0_b.exit.i

_ZN6parlay6par_doIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvT_T0_b.exit.i: ; preds = %det.cont.i.i
  tail call void @llvm.sync.unwind(token %syncreg.i.i)
  br label %_ZN6parlayL9par_do_ifIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvbT_T0_b.exit

if.else.i:                                        ; preds = %if.else16
  %add.ptr3.i.i.i = getelementptr inbounds %"struct.std::pair.149.202.511.818.1125.1432.1739.2046", %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, i64 %add8.i
  %call2.i.i = tail call %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce0, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr3.i.i.i, i32 %sub)
  %call2.i6.i = tail call %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveEN6parlay5sliceIPSt4pairImPS3_ESA_EEi(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %add.ptr3.i.i.i, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"* %Pts.coerce1, i32 %sub)
  store %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %call2.i6.i, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %R, align 8, !tbaa !13
  br label %_ZN6parlayL9par_do_ifIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvbT_T0_b.exit

_ZN6parlayL9par_do_ifIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvbT_T0_b.exit: ; preds = %if.else.i, %_ZN6parlay6par_doIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvT_T0_b.exit.i
  %L.0 = phi %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* [ %call2.i, %_ZN6parlay6par_doIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvT_T0_b.exit.i ], [ %call2.i.i, %if.else.i ]
  %R.0. = load %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"** %R, align 8, !tbaa !13
  %call20 = tail call %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_nodeEPS5_S6_(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %L.0, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %R.0.)
  call void @llvm.lifetime.end.p0i8(i64 8, i8* nonnull %R.0..sroa_cast)
  br label %cleanup24

cleanup24:                                        ; preds = %_ZN6parlayL9par_do_ifIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvbT_T0_b.exit, %if.then12, %_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_leafEN6parlay5sliceIPSt4pairImPS3_ESB_EE.exit
  %retval.1 = phi %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* [ %12, %_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_leafEN6parlay5sliceIPSt4pairImPS3_ESB_EE.exit ], [ %call15, %if.then12 ], [ %call20, %_ZN6parlayL9par_do_ifIZN8oct_treeI6vertexI7point2dIdEEE15build_recursiveENS_5sliceIPSt4pairImPS5_ESB_EEiEUlvE_ZNS6_15build_recursiveESC_iEUlvE0_EEvbT_T0_b.exit ]
  ret %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* %retval.1
}

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal6reduceINS_5sliceINS_16delayed_sequenceISt4pairI7point2dIdES6_EZN8oct_treeI6vertexIS6_EE7get_boxINS_8sequenceIPSA_NS_9allocatorISE_EEEEEES7_RT_EUlmE_E8iteratorESM_EENS_6monoidIZNSC_ISH_EES7_SJ_EUlS7_S7_E_S7_EEEENSI_10value_typeERKSI_T0_j(%"struct.std::pair.109.420.727.1034.1341.1648.1955"* noalias sret, %"struct.parlay::slice.161.206.515.822.1129.1436.1743.2050"* dereferenceable(32), %"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052"* byval(%"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052") align 8, i32) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal6reduceINS_8sequenceISt4pairI7point2dIdES5_ENS_9allocatorIS6_EEEENS_6monoidIZN8oct_treeI6vertexIS5_EE7get_boxINS2_IPSD_NS7_ISG_EEEEEES6_RT_EUlS6_S6_E_S6_EEEENSJ_10value_typeERKSJ_T0_j(%"struct.std::pair.109.420.727.1034.1341.1648.1955"* noalias sret, %"class.parlay::sequence.162.217.526.833.1140.1447.1754.2061"* dereferenceable(15), %"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052"* byval(%"struct.parlay::monoid.160.208.517.824.1131.1438.1745.2052") align 8, i32) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_5sliceINS_16delayed_sequenceISt4pairI7point2dIdES8_EZN8oct_treeI6vertexIS8_EE7get_boxINS_8sequenceIPSC_NS_9allocatorISG_EEEEEES9_RT_EUlmE_E8iteratorESO_EENS_6monoidIZNSE_ISJ_EES9_SL_EUlS9_S9_E_S9_EEEENSK_10value_typeERKSK_T0_jEUlmmmE_EEvmmSV_jEUlmE_EEvmmSK_mb(i64, i64, %class.anon.170.219.528.835.1142.1449.1756.2063* byval(%class.anon.170.219.528.835.1142.1449.1756.2063) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZZN6parlay8internal6reduceINS_5sliceINS_16delayed_sequenceISt4pairI7point2dIdES6_EZN8oct_treeI6vertexIS6_EE7get_boxINS_8sequenceIPSA_NS_9allocatorISE_EEEEEES7_RT_EUlmE_E8iteratorESM_EENS_6monoidIZNSC_ISH_EES7_SJ_EUlS7_S7_E_S7_EEEENSI_10value_typeERKSI_T0_jENKUlmmmE_clEmmm(%class.anon.168.218.527.834.1141.1448.1755.2062*, i64, i64, i64) local_unnamed_addr #6 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_6reduceINS_8sequenceISt4pairI7point2dIdES7_ENS_9allocatorIS8_EEEENS_6monoidIZN8oct_treeI6vertexIS7_EE7get_boxINS4_IPSF_NS9_ISI_EEEEEES8_RT_EUlS8_S8_E_S8_EEEENSL_10value_typeERKSL_T0_jEUlmmmE_EEvmmSR_jEUlmE_EEvmmSL_mb(i64, i64, %class.anon.172.221.530.837.1144.1451.1758.2065* byval(%class.anon.172.221.530.837.1144.1451.1758.2065) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal11sample_sortINS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlmE_E8iteratorEZNSB_10tag_pointsESG_EUlS9_S9_E_EEDaNS_5sliceIT_SM_EERKT0_b(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"* noalias sret, %"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"* byval(%"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069") align 8, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1), i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal12sample_sort_IjNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlmE_E8iteratorEPS9_ZNSB_10tag_pointsESG_EUlS9_S9_E_EEvNS_5sliceIT0_SN_EENSM_IT1_SP_EERKT2_b(%"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"* byval(%"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069") align 8, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1), i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal12sample_sort_ImNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlmE_E8iteratorEPS9_ZNSB_10tag_pointsESG_EUlS9_S9_E_EEvNS_5sliceIT0_SN_EENSM_IT1_SP_EERKT2_b(%"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069"* byval(%"struct.parlay::slice.174.225.534.841.1148.1455.1762.2069") align 8, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1), i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEEC2EmNSA_18_uninitialized_tagE(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, i64) unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal9quicksortIPSt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS6_E10tag_pointsERNS_8sequenceIS7_NS_9allocatorIS7_EEEEEUlS8_S8_E_EEvT_mRKT0_(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, i64, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSB_IT2_NSC_ISH_EEEEmmmm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* noalias sret, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* dereferenceable(15), i64, i64, i64, i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal12sample_sort_IjNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS8_E10tag_pointsERNS_8sequenceIS9_NS_9allocatorIS9_EEEEEUlmE_E8iteratorEPSA_ZNSC_10tag_pointsESH_EUlSA_SA_E_EEvNS_5sliceIT0_SO_EENSN_IT1_SQ_EERKT2_bEUlmE1_EEvmmT_mb(i64, i64, %class.anon.184.237.546.853.1160.1467.1774.2081* byval(%class.anon.184.237.546.853.1160.1467.1774.2081) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local { i64, %struct.vertex.52.363.670.977.1284.1591.1898* } @_ZNK6parlay16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS5_E10tag_pointsERNS_8sequenceIS6_NS_9allocatorIS6_EEEEEUlmE_E8iteratorixEm(%"class.parlay::delayed_sequence<std::pair<unsigned long, vertex<point2d<double> > *>, (lambda at ./oct_tree.h:252:57)>::iterator.224.533.840.1147.1454.1761.2068"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: nounwind readnone speculatable willreturn
declare double @llvm.floor.f64(double) #12

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal18merge_sort_inplaceIPSt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS6_E10tag_pointsERNS_8sequenceIS7_NS_9allocatorIS7_EEEEEUlS8_S8_E_EEvNS_5sliceIT_SJ_EERKT0_(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal11merge_sort_IPSt4pairImP6vertexI7point2dIdEEES9_ZN8oct_treeIS6_E10tag_pointsERNS_8sequenceIS7_NS_9allocatorIS7_EEEEEUlS8_S8_E_EEvNS_5sliceIT_SJ_EENSI_IT0_SL_EERKT1_b(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1), i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10merge_intoINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_SA_ZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlS9_S9_E_EEvNS_5sliceIT0_SK_EENSJ_IT1_SM_EENSJ_IT2_SO_EERKT3_b(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1), i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal9seq_mergeINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_SA_ZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlS9_S9_E_EEvNS_5sliceIT0_SK_EENSJ_IT1_SM_EENSJ_IT2_SO_EERKT3_(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEEC2IZNS_8internal12sample_sort_IjNS_16delayed_sequenceIS7_ZN8oct_treeIS5_E10tag_pointsERNS0_IS6_NS8_IS6_EEEEEUlmE_E8iteratorEPS7_ZNSG_10tag_pointsESJ_EUlS7_S7_E_EEvNS_5sliceIT0_SQ_EENSP_IT1_SS_EERKT2_bEUlmE_EEmOT_NSA_18_from_function_tagEm(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, i64, %class.anon.175.238.547.854.1161.1468.1775.2082* dereferenceable(16), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS8_EEEC1IZNS_8internal12sample_sort_IjNS_16delayed_sequenceIS8_ZN8oct_treeIS6_E10tag_pointsERNS1_IS7_NS9_IS7_EEEEEUlmE_E8iteratorEPS8_ZNSH_10tag_pointsESK_EUlS8_S8_E_EEvNS_5sliceIT0_SR_EENSQ_IT1_ST_EERKT2_bEUlmE_EEmOT_NSB_18_from_function_tagEmEUlmE_EEvmmSZ_mb(i64, i64, %class.anon.191.239.548.855.1162.1469.1776.2083* byval(%class.anon.191.239.548.855.1162.1469.1776.2083) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal16quicksort_serialIPSt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS6_E10tag_pointsERNS_8sequenceIS7_NS_9allocatorIS7_EEEEEUlS8_S8_E_EEvT_mRKT0_(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, i64, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal6split3IPSt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS6_E10tag_pointsERNS_8sequenceIS7_NS_9allocatorIS7_EEEEEUlS8_S8_E_EESt5tupleIJT_SJ_bEESJ_mRKT0_(%"class.std::tuple.192.246.555.862.1169.1476.1783.2090"* noalias sret, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, i64, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal5sort5IPSt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS6_E10tag_pointsERNS_8sequenceIS7_NS_9allocatorIS7_EEEEEUlS8_S8_E_EEvT_mRKT0_(%"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, i64, %class.anon.154.226.535.842.1149.1456.1763.2070* dereferenceable(1)) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEEC2IZNS_8internal12sample_sort_IjNS_16delayed_sequenceIS7_ZN8oct_treeIS5_E10tag_pointsERNS0_IS6_NS8_IS6_EEEEEUlmE_E8iteratorEPS7_ZNSG_10tag_pointsESJ_EUlS7_S7_E_EEvNS_5sliceIT0_SQ_EENSP_IT1_SS_EERKT2_bEUlmE0_EEmOT_NSA_18_from_function_tagEm(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, i64, %class.anon.176.247.556.863.1170.1477.1784.2091* dereferenceable(8), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS8_EEEC1IZNS_8internal12sample_sort_IjNS_16delayed_sequenceIS8_ZN8oct_treeIS6_E10tag_pointsERNS1_IS7_NS9_IS7_EEEEEUlmE_E8iteratorEPS8_ZNSH_10tag_pointsESK_EUlS8_S8_E_EEvNS_5sliceIT0_SR_EENSQ_IT1_ST_EERKT2_bEUlmE0_EEmOT_NSB_18_from_function_tagEmEUlmE_EEvmmSZ_mb(i64, i64, %class.anon.203.248.557.864.1171.1478.1785.2092* byval(%class.anon.203.248.557.864.1171.1478.1785.2092) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceIjNS_9allocatorIjEEEC2EmNS3_18_uninitialized_tagE(%"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_12sample_sort_IjNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS9_E10tag_pointsERNS_8sequenceISA_NS_9allocatorISA_EEEEEUlmE_E8iteratorEPSB_ZNSD_10tag_pointsESI_EUlSB_SB_E_EEvNS_5sliceIT0_SP_EENSO_IT1_SR_EERKT2_bEUlmmmE_EEvmmRKT_jEUlmE_EEvmmSX_mb(i64, i64, %class.anon.204.252.561.868.1175.1482.1789.2096* byval(%class.anon.204.252.561.868.1175.1482.1789.2096) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZZN6parlay8internal12sample_sort_IjNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlmE_E8iteratorEPS9_ZNSB_10tag_pointsESG_EUlS9_S9_E_EEvNS_5sliceIT0_SN_EENSM_IT1_SP_EERKT2_bENKUlmmmE_clEmmm(%class.anon.183.251.560.867.1174.1481.1788.2095*, i64, i64, i64) local_unnamed_addr #6 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESB_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSC_IT2_NSD_ISI_EEEEmmmmEUlmE0_EEvmmT_mb(i64, i64, %class.anon.208.253.562.869.1176.1483.1790.2097* byval(%class.anon.208.253.562.869.1176.1483.1790.2097) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceIjNS_9allocatorIjEEEC2IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEENS0_ImNS1_ImEEEET0_T1_RNS0_IT2_NS1_ISK_EEEEmmmmEUlmE_EEmOT_NS3_18_from_function_tagEm(%"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64, %class.anon.207.254.563.870.1177.1484.1791.2098* dereferenceable(32), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIjNS_9allocatorIjEEEC1IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_jEENS1_ImNS2_ImEEEET0_T1_RNS1_IT2_NS2_ISL_EEEEmmmmEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSR_mb(i64, i64, %class.anon.210.255.564.871.1178.1485.1792.2099* byval(%class.anon.210.255.564.871.1178.1485.1792.2099) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local i32 @_ZN6parlay8internal5scan_INS_5sliceIPjS3_EES4_NS_4addmIjEEEENT_10value_typeERKS7_T0_RKT1_jb(%"struct.parlay::slice.205.256.565.872.1179.1486.1793.2100"* dereferenceable(16), i32*, i32*, %"struct.parlay::addm.206.257.566.873.1180.1487.1794.2101"* dereferenceable(4), i32, i1 zeroext) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPjS5_EES6_NS_4addmIjEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE_EEvmmSC_jEUlmE_EEvmmS9_mb(i64, i64, %class.anon.213.259.568.875.1182.1489.1796.2103* byval(%class.anon.213.259.568.875.1182.1489.1796.2103) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_5scan_INS_5sliceIPjS5_EES6_NS_4addmIjEEEENT_10value_typeERKS9_T0_RKT1_jbEUlmmmE0_EEvmmSC_jEUlmE_EEvmmS9_mb(i64, i64, %class.anon.214.261.570.877.1184.1491.1798.2105* byval(%class.anon.214.261.570.877.1184.1491.1798.2105) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSB_IT2_NSC_ISH_EEEEmmmmENKUlmE0_clEm(%class.anon.208.253.562.869.1176.1483.1790.2097*, i64) local_unnamed_addr #6 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceIjNS_9allocatorIjEEE18initialize_defaultEm(%"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIjNS_9allocatorIjEEE18initialize_defaultEmEUlmE_EEvmmT_mb(i64, i64, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, i32**, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal9transposeINS_26uninitialized_relocate_tagEPjE6transREmmmmmm(%"struct.parlay::internal::transpose.262.571.878.1185.1492.1799.2106"*, i64, i64, i64, i64, i64, i64) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10blockTransINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_PjSB_E6transREmmmmmm(%"struct.parlay::internal::blockTrans.263.572.879.1186.1493.1800.2107"*, i64, i64, i64, i64, i64, i64) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64, %class.anon.209.265.573.880.1187.1494.1801.2108* dereferenceable(32), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
define linkonce_odr dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_jEES4_T0_T1_RNS1_IT2_NS2_ISJ_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSO_mb(i64 %start, i64 %end, %class.anon.225.266.574.881.1188.1495.1802.2109* byval(%class.anon.225.266.574.881.1188.1495.1802.2109) align 8 %f, i64 %granularity, i1 zeroext %0) local_unnamed_addr #6 comdat {
entry:
  %syncreg19 = tail call token @llvm.syncregion.start()
  %cmp = icmp eq i64 %granularity, 0
  br i1 %cmp, label %if.then, label %if.else

if.then:                                          ; preds = %entry
  %cmp1 = icmp ugt i64 %end, %start
  br i1 %cmp1, label %pfor.ph, label %sync.continue23

pfor.ph:                                          ; preds = %if.then
  %sub = sub i64 %end, %start
  %1 = getelementptr inbounds %class.anon.225.266.574.881.1188.1495.1802.2109, %class.anon.225.266.574.881.1188.1495.1802.2109* %f, i64 0, i32 1
  %2 = load i64**, i64*** %1, align 8, !tbaa !121
  %3 = load i64*, i64** %2, align 8, !tbaa !13
  %4 = getelementptr inbounds %class.anon.225.266.574.881.1188.1495.1802.2109, %class.anon.225.266.574.881.1188.1495.1802.2109* %f, i64 0, i32 2
  %5 = load %class.anon.209.265.573.880.1187.1494.1801.2108*, %class.anon.209.265.573.880.1187.1494.1801.2108** %4, align 8, !tbaa !123
  %6 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %5, i64 0, i32 0
  %7 = load i64*, i64** %6, align 8, !tbaa !124
  %8 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %5, i64 0, i32 2
  %9 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %5, i64 0, i32 3
  %10 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %5, i64 0, i32 1
  %11 = xor i64 %start, -1
  %12 = add i64 %11, %end
  %xtraiter = and i64 %sub, 2047
  %13 = icmp ult i64 %12, 2047
  br i1 %13, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.ph.new

pfor.ph.new:                                      ; preds = %pfor.ph
  %stripiter = lshr i64 %sub, 11
  br label %pfor.cond.strpm.outer

pfor.cond.strpm.outer:                            ; preds = %pfor.inc.strpm.outer, %pfor.ph.new
  %niter = phi i64 [ 0, %pfor.ph.new ], [ %niter.nadd, %pfor.inc.strpm.outer ]
  detach within %syncreg19, label %pfor.body.strpm.outer, label %pfor.inc.strpm.outer

pfor.body.strpm.outer:                            ; preds = %pfor.cond.strpm.outer
  %14 = shl i64 %niter, 11
  br label %pfor.cond

pfor.cond:                                        ; preds = %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit, %pfor.body.strpm.outer
  %__begin.0 = phi i64 [ %inc, %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit ], [ %14, %pfor.body.strpm.outer ]
  %inneriter = phi i64 [ %inneriter.nsub, %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit ], [ 2048, %pfor.body.strpm.outer ]
  %add3 = add i64 %__begin.0, %start
  %arrayidx.i = getelementptr inbounds i64, i64* %3, i64 %add3
  %15 = load i64, i64* %7, align 8, !tbaa !14
  %cmp.i.i = icmp eq i64 %15, %add3
  br i1 %cmp.i.i, label %cond.true.i.i, label %cond.false.i.i

cond.true.i.i:                                    ; preds = %pfor.cond
  %16 = load i64*, i64** %10, align 8, !tbaa !126
  %17 = load i64, i64* %16, align 8, !tbaa !14
  br label %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit

cond.false.i.i:                                   ; preds = %pfor.cond
  %18 = load %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"** %8, align 8, !tbaa !127
  %19 = load i64*, i64** %9, align 8, !tbaa !128
  %20 = load i64, i64* %19, align 8, !tbaa !14
  %mul.i.i = mul i64 %20, %add3
  %flag.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079", %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %18, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i.i = load i8, i8* %flag.i.i.i.i.i.i, align 1
  %cmp.i.i.i.i.i.i = icmp sgt i8 %bf.load.i.i.i.i.i.i, -1
  br i1 %cmp.i.i.i.i.i.i, label %if.then.i.i.i.i.i, label %if.else.i.i.i.i.i

if.then.i.i.i.i.i:                                ; preds = %cond.false.i.i
  %21 = bitcast %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %18 to i32*
  br label %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i

if.else.i.i.i.i.i:                                ; preds = %cond.false.i.i
  %buffer.i.i.i.i.i.i.i = getelementptr inbounds %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079", %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %18, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %22 = load %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"*, %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"** %buffer.i.i.i.i.i.i.i, align 1, !tbaa !129
  %data.i.i.i.i.i.i.i.i = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072", %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"* %22, i64 0, i32 1, i32 0
  %23 = bitcast [1 x i8]* %data.i.i.i.i.i.i.i.i to i32*
  br label %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i

_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i: ; preds = %if.else.i.i.i.i.i, %if.then.i.i.i.i.i
  %retval.0.i.i.i.i.i = phi i32* [ %21, %if.then.i.i.i.i.i ], [ %23, %if.else.i.i.i.i.i ]
  %arrayidx.i.i.i.i = getelementptr inbounds i32, i32* %retval.0.i.i.i.i.i, i64 %mul.i.i
  %24 = load i32, i32* %arrayidx.i.i.i.i, align 4, !tbaa !57
  %conv.i.i = zext i32 %24 to i64
  br label %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit

_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit: ; preds = %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i, %cond.true.i.i
  %cond.i.i = phi i64 [ %17, %cond.true.i.i ], [ %conv.i.i, %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i ]
  store i64 %cond.i.i, i64* %arrayidx.i, align 8, !tbaa !14
  %inc = add nuw i64 %__begin.0, 1
  %inneriter.nsub = add nsw i64 %inneriter, -1
  %inneriter.ncmp = icmp eq i64 %inneriter.nsub, 0
  br i1 %inneriter.ncmp, label %pfor.inc.reattach, label %pfor.cond, !llvm.loop !131

pfor.inc.reattach:                                ; preds = %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit
  reattach within %syncreg19, label %pfor.inc.strpm.outer

pfor.inc.strpm.outer:                             ; preds = %pfor.inc.reattach, %pfor.cond.strpm.outer
  %niter.nadd = add nuw i64 %niter, 1
  %niter.ncmp = icmp eq i64 %niter.nadd, %stripiter
  br i1 %niter.ncmp, label %pfor.cond.cleanup.strpm-lcssa, label %pfor.cond.strpm.outer, !llvm.loop !132

pfor.cond.cleanup.strpm-lcssa:                    ; preds = %pfor.inc.strpm.outer, %pfor.ph
  %lcmp.mod = icmp eq i64 %xtraiter, 0
  br i1 %lcmp.mod, label %pfor.cond.cleanup, label %pfor.cond.epil.preheader

pfor.cond.epil.preheader:                         ; preds = %pfor.cond.cleanup.strpm-lcssa
  %25 = and i64 %sub, -2048
  br label %pfor.cond.epil

pfor.cond.epil:                                   ; preds = %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil, %pfor.cond.epil.preheader
  %__begin.0.epil = phi i64 [ %25, %pfor.cond.epil.preheader ], [ %inc.epil, %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil ]
  %epil.iter = phi i64 [ %xtraiter, %pfor.cond.epil.preheader ], [ %epil.iter.sub, %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil ]
  %add3.epil = add i64 %__begin.0.epil, %start
  %arrayidx.i.epil = getelementptr inbounds i64, i64* %3, i64 %add3.epil
  %26 = load i64, i64* %7, align 8, !tbaa !14
  %cmp.i.i.epil = icmp eq i64 %26, %add3.epil
  br i1 %cmp.i.i.epil, label %cond.true.i.i.epil, label %cond.false.i.i.epil

cond.false.i.i.epil:                              ; preds = %pfor.cond.epil
  %27 = load %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"** %8, align 8, !tbaa !127
  %28 = load i64*, i64** %9, align 8, !tbaa !128
  %29 = load i64, i64* %28, align 8, !tbaa !14
  %mul.i.i.epil = mul i64 %29, %add3.epil
  %flag.i.i.i.i.i.i.epil = getelementptr inbounds %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079", %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %27, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i.i.epil = load i8, i8* %flag.i.i.i.i.i.i.epil, align 1
  %cmp.i.i.i.i.i.i.epil = icmp sgt i8 %bf.load.i.i.i.i.i.i.epil, -1
  br i1 %cmp.i.i.i.i.i.i.epil, label %if.then.i.i.i.i.i.epil, label %if.else.i.i.i.i.i.epil

if.else.i.i.i.i.i.epil:                           ; preds = %cond.false.i.i.epil
  %buffer.i.i.i.i.i.i.i.epil = getelementptr inbounds %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079", %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %27, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %30 = load %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"*, %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"** %buffer.i.i.i.i.i.i.i.epil, align 1, !tbaa !129
  %data.i.i.i.i.i.i.i.i.epil = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072", %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"* %30, i64 0, i32 1, i32 0
  %31 = bitcast [1 x i8]* %data.i.i.i.i.i.i.i.i.epil to i32*
  br label %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i.epil

if.then.i.i.i.i.i.epil:                           ; preds = %cond.false.i.i.epil
  %32 = bitcast %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %27 to i32*
  br label %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i.epil

_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i.epil: ; preds = %if.then.i.i.i.i.i.epil, %if.else.i.i.i.i.i.epil
  %retval.0.i.i.i.i.i.epil = phi i32* [ %32, %if.then.i.i.i.i.i.epil ], [ %31, %if.else.i.i.i.i.i.epil ]
  %arrayidx.i.i.i.i.epil = getelementptr inbounds i32, i32* %retval.0.i.i.i.i.i.epil, i64 %mul.i.i.epil
  %33 = load i32, i32* %arrayidx.i.i.i.i.epil, align 4, !tbaa !57
  %conv.i.i.epil = zext i32 %33 to i64
  br label %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil

cond.true.i.i.epil:                               ; preds = %pfor.cond.epil
  %34 = load i64*, i64** %10, align 8, !tbaa !126
  %35 = load i64, i64* %34, align 8, !tbaa !14
  br label %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil

_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil: ; preds = %cond.true.i.i.epil, %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i.epil
  %cond.i.i.epil = phi i64 [ %35, %cond.true.i.i.epil ], [ %conv.i.i.epil, %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i.epil ]
  store i64 %cond.i.i.epil, i64* %arrayidx.i.epil, align 8, !tbaa !14
  %inc.epil = add nuw nsw i64 %__begin.0.epil, 1
  %epil.iter.sub = add nsw i64 %epil.iter, -1
  %epil.iter.cmp = icmp eq i64 %epil.iter.sub, 0
  br i1 %epil.iter.cmp, label %pfor.cond.cleanup, label %pfor.cond.epil, !llvm.loop !133

pfor.cond.cleanup:                                ; preds = %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit.epil, %pfor.cond.cleanup.strpm-lcssa
  sync within %syncreg19, label %sync.continue

sync.continue:                                    ; preds = %pfor.cond.cleanup
  tail call void @llvm.sync.unwind(token %syncreg19)
  br label %sync.continue23

if.else:                                          ; preds = %entry
  %sub6 = sub i64 %end, %start
  %cmp7 = icmp ugt i64 %sub6, %granularity
  br i1 %cmp7, label %if.else13.tf, label %for.cond.preheader

for.cond.preheader:                               ; preds = %if.else
  %cmp1047 = icmp ugt i64 %end, %start
  br i1 %cmp1047, label %for.body.lr.ph, label %sync.continue23

for.body.lr.ph:                                   ; preds = %for.cond.preheader
  %36 = getelementptr inbounds %class.anon.225.266.574.881.1188.1495.1802.2109, %class.anon.225.266.574.881.1188.1495.1802.2109* %f, i64 0, i32 1
  %37 = load i64**, i64*** %36, align 8, !tbaa !121
  %38 = load i64*, i64** %37, align 8, !tbaa !13
  %39 = getelementptr inbounds %class.anon.225.266.574.881.1188.1495.1802.2109, %class.anon.225.266.574.881.1188.1495.1802.2109* %f, i64 0, i32 2
  %40 = load %class.anon.209.265.573.880.1187.1494.1801.2108*, %class.anon.209.265.573.880.1187.1494.1801.2108** %39, align 8, !tbaa !123
  %41 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %40, i64 0, i32 0
  %42 = load i64*, i64** %41, align 8, !tbaa !124
  %43 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %40, i64 0, i32 2
  %44 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %40, i64 0, i32 3
  %45 = getelementptr inbounds %class.anon.209.265.573.880.1187.1494.1801.2108, %class.anon.209.265.573.880.1187.1494.1801.2108* %40, i64 0, i32 1
  br label %for.body

for.body:                                         ; preds = %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit46, %for.body.lr.ph
  %i9.048 = phi i64 [ %start, %for.body.lr.ph ], [ %inc11, %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit46 ]
  %arrayidx.i29 = getelementptr inbounds i64, i64* %38, i64 %i9.048
  %46 = load i64, i64* %42, align 8, !tbaa !14
  %cmp.i.i30 = icmp eq i64 %46, %i9.048
  br i1 %cmp.i.i30, label %cond.true.i.i31, label %cond.false.i.i36

cond.true.i.i31:                                  ; preds = %for.body
  %47 = load i64*, i64** %45, align 8, !tbaa !126
  %48 = load i64, i64* %47, align 8, !tbaa !14
  br label %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit46

cond.false.i.i36:                                 ; preds = %for.body
  %49 = load %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"*, %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"** %43, align 8, !tbaa !127
  %50 = load i64*, i64** %44, align 8, !tbaa !128
  %51 = load i64, i64* %50, align 8, !tbaa !14
  %mul.i.i32 = mul i64 %51, %i9.048
  %flag.i.i.i.i.i.i33 = getelementptr inbounds %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079", %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %49, i64 0, i32 0, i32 0, i32 0, i32 1
  %bf.load.i.i.i.i.i.i34 = load i8, i8* %flag.i.i.i.i.i.i33, align 1
  %cmp.i.i.i.i.i.i35 = icmp sgt i8 %bf.load.i.i.i.i.i.i34, -1
  br i1 %cmp.i.i.i.i.i.i35, label %if.then.i.i.i.i.i37, label %if.else.i.i.i.i.i40

if.then.i.i.i.i.i37:                              ; preds = %cond.false.i.i36
  %52 = bitcast %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %49 to i32*
  br label %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i44

if.else.i.i.i.i.i40:                              ; preds = %cond.false.i.i36
  %buffer.i.i.i.i.i.i.i38 = getelementptr inbounds %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079", %"class.parlay::sequence.177.235.544.851.1158.1465.1772.2079"* %49, i64 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0, i32 0
  %53 = load %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"*, %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"** %buffer.i.i.i.i.i.i.i38, align 1, !tbaa !129
  %data.i.i.i.i.i.i.i.i39 = getelementptr inbounds %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072", %"struct.parlay::_sequence_base<unsigned int, parlay::allocator<unsigned int> >::_sequence_impl::capacitated_buffer::header.228.537.844.1151.1458.1765.2072"* %53, i64 0, i32 1, i32 0
  %54 = bitcast [1 x i8]* %data.i.i.i.i.i.i.i.i39 to i32*
  br label %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i44

_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i44: ; preds = %if.else.i.i.i.i.i40, %if.then.i.i.i.i.i37
  %retval.0.i.i.i.i.i41 = phi i32* [ %52, %if.then.i.i.i.i.i37 ], [ %54, %if.else.i.i.i.i.i40 ]
  %arrayidx.i.i.i.i42 = getelementptr inbounds i32, i32* %retval.0.i.i.i.i.i41, i64 %mul.i.i32
  %55 = load i32, i32* %arrayidx.i.i.i.i42, align 4, !tbaa !57
  %conv.i.i43 = zext i32 %55 to i64
  br label %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit46

_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit46: ; preds = %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i44, %cond.true.i.i31
  %cond.i.i45 = phi i64 [ %48, %cond.true.i.i31 ], [ %conv.i.i43, %_ZN6parlay8sequenceIjNS_9allocatorIjEEEixEm.exit.i.i44 ]
  store i64 %cond.i.i45, i64* %arrayidx.i29, align 8, !tbaa !14
  %inc11 = add nuw i64 %i9.048, 1
  %exitcond50 = icmp eq i64 %inc11, %end
  br i1 %exitcond50, label %sync.continue23, label %for.body

if.else13.tf:                                     ; preds = %if.else
  %56 = mul i64 %sub6, 9
  %mul16 = add i64 %56, 9
  %div17 = lshr i64 %mul16, 4
  %add18 = add i64 %div17, %start
  %57 = bitcast %class.anon.225.266.574.881.1188.1495.1802.2109* %f to i8*
  %58 = tail call token @llvm.taskframe.create()
  %agg.tmp = alloca %class.anon.225.266.574.881.1188.1495.1802.2109, align 8
  %59 = bitcast %class.anon.225.266.574.881.1188.1495.1802.2109* %agg.tmp to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* nonnull align 8 dereferenceable(24) %59, i8* nonnull align 8 dereferenceable(24) %57, i64 24, i1 false), !tbaa.struct !134
  detach within %syncreg19, label %det.achd, label %det.cont

det.achd:                                         ; preds = %if.else13.tf
  tail call void @llvm.taskframe.use(token %58)
  tail call void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_jEES4_T0_T1_RNS1_IT2_NS2_ISJ_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSO_mb(i64 %start, i64 %add18, %class.anon.225.266.574.881.1188.1495.1802.2109* nonnull byval(%class.anon.225.266.574.881.1188.1495.1802.2109) align 8 %agg.tmp, i64 %granularity, i1 zeroext false)
  reattach within %syncreg19, label %det.cont

det.cont:                                         ; preds = %det.achd, %if.else13.tf
  tail call void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_jEES4_T0_T1_RNS1_IT2_NS2_ISJ_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSO_mb(i64 %add18, i64 %end, %class.anon.225.266.574.881.1188.1495.1802.2109* nonnull byval(%class.anon.225.266.574.881.1188.1495.1802.2109) align 8 %f, i64 %granularity, i1 zeroext false)
  sync within %syncreg19, label %sync.continue21

sync.continue21:                                  ; preds = %det.cont
  tail call void @llvm.sync.unwind(token %syncreg19)
  br label %sync.continue23

sync.continue23:                                  ; preds = %sync.continue21, %_ZZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmENKUlmE_clEm.exit46, %for.cond.preheader, %sync.continue, %if.then
  ret void
}

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSB_IT2_NSC_ISH_EEEEmmmm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* noalias sret, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* dereferenceable(15), i64, i64, i64, i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal12sample_sort_ImNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS8_E10tag_pointsERNS_8sequenceIS9_NS_9allocatorIS9_EEEEEUlmE_E8iteratorEPSA_ZNSC_10tag_pointsESH_EUlSA_SA_E_EEvNS_5sliceIT0_SO_EENSN_IT1_SQ_EERKT2_bEUlmE1_EEvmmT_mb(i64, i64, %class.anon.229.267.575.882.1189.1496.1803.2110* byval(%class.anon.229.267.575.882.1189.1496.1803.2110) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEEC2IZNS_8internal12sample_sort_ImNS_16delayed_sequenceIS7_ZN8oct_treeIS5_E10tag_pointsERNS0_IS6_NS8_IS6_EEEEEUlmE_E8iteratorEPS7_ZNSG_10tag_pointsESJ_EUlS7_S7_E_EEvNS_5sliceIT0_SQ_EENSP_IT1_SS_EERKT2_bEUlmE_EEmOT_NSA_18_from_function_tagEm(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, i64, %class.anon.226.268.576.883.1190.1497.1804.2111* dereferenceable(16), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS8_EEEC1IZNS_8internal12sample_sort_ImNS_16delayed_sequenceIS8_ZN8oct_treeIS6_E10tag_pointsERNS1_IS7_NS9_IS7_EEEEEUlmE_E8iteratorEPS8_ZNSH_10tag_pointsESK_EUlS8_S8_E_EEvNS_5sliceIT0_SR_EENSQ_IT1_ST_EERKT2_bEUlmE_EEmOT_NSB_18_from_function_tagEmEUlmE_EEvmmSZ_mb(i64, i64, %class.anon.230.269.577.884.1191.1498.1805.2112* byval(%class.anon.230.269.577.884.1191.1498.1805.2112) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEEC2IZNS_8internal12sample_sort_ImNS_16delayed_sequenceIS7_ZN8oct_treeIS5_E10tag_pointsERNS0_IS6_NS8_IS6_EEEEEUlmE_E8iteratorEPS7_ZNSG_10tag_pointsESJ_EUlS7_S7_E_EEvNS_5sliceIT0_SQ_EENSP_IT1_SS_EERKT2_bEUlmE0_EEmOT_NSA_18_from_function_tagEm(%"class.parlay::sequence.142.201.510.817.1124.1431.1738.2045"*, i64, %class.anon.227.270.578.885.1192.1499.1806.2113* dereferenceable(8), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS8_EEEC1IZNS_8internal12sample_sort_ImNS_16delayed_sequenceIS8_ZN8oct_treeIS6_E10tag_pointsERNS1_IS7_NS9_IS7_EEEEEUlmE_E8iteratorEPS8_ZNSH_10tag_pointsESK_EUlS8_S8_E_EEvNS_5sliceIT0_SR_EENSQ_IT1_ST_EERKT2_bEUlmE0_EEmOT_NSB_18_from_function_tagEmEUlmE_EEvmmSZ_mb(i64, i64, %class.anon.231.271.579.886.1193.1500.1807.2114* byval(%class.anon.231.271.579.886.1193.1500.1807.2114) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceImNS_9allocatorImEEEC2EmNS3_18_uninitialized_tagE(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_12sample_sort_ImNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS9_E10tag_pointsERNS_8sequenceISA_NS_9allocatorISA_EEEEEUlmE_E8iteratorEPSB_ZNSD_10tag_pointsESI_EUlSB_SB_E_EEvNS_5sliceIT0_SP_EENSO_IT1_SR_EERKT2_bEUlmmmE_EEvmmRKT_jEUlmE_EEvmmSX_mb(i64, i64, %class.anon.232.273.581.888.1195.1502.1809.2116* byval(%class.anon.232.273.581.888.1195.1502.1809.2116) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZZN6parlay8internal12sample_sort_ImNS_16delayed_sequenceISt4pairImP6vertexI7point2dIdEEEZN8oct_treeIS7_E10tag_pointsERNS_8sequenceIS8_NS_9allocatorIS8_EEEEEUlmE_E8iteratorEPS9_ZNSB_10tag_pointsESG_EUlS9_S9_E_EEvNS_5sliceIT0_SN_EENSM_IT1_SP_EERKT2_bENKUlmmmE_clEmmm(%class.anon.228.272.580.887.1194.1501.1808.2115*, i64, i64, i64) local_unnamed_addr #6 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESB_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSC_IT2_NSD_ISI_EEEEmmmmEUlmE0_EEvmmT_mb(i64, i64, %class.anon.234.274.582.889.1196.1503.1810.2117* byval(%class.anon.234.274.582.889.1196.1503.1810.2117) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceImNS_9allocatorImEEEC2IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_mEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE_EEmOT_NS3_18_from_function_tagEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64, %class.anon.233.275.583.890.1197.1504.1811.2118* dereferenceable(32), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IRZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_mEES4_T0_T1_RNS1_IT2_NS2_ISJ_EEEEmmmmEUlmE_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSP_mb(i64, i64, %class.anon.238.276.584.891.1198.1505.1812.2119* byval(%class.anon.238.276.584.891.1198.1505.1812.2119) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_mEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSB_IT2_NSC_ISH_EEEEmmmmENKUlmE0_clEm(%class.anon.234.274.582.889.1196.1503.1810.2117*, i64) local_unnamed_addr #6 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal9transposeINS_26uninitialized_relocate_tagEPmE6transREmmmmmm(%"struct.parlay::internal::transpose.235.277.585.892.1199.1506.1813.2120"*, i64, i64, i64, i64, i64, i64) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10blockTransINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_PmSB_E6transREmmmmmm(%"struct.parlay::internal::blockTrans.236.278.586.893.1200.1507.1814.2121"*, i64, i64, i64, i64, i64, i64) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_mEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64, %class.anon.237.280.587.894.1201.1508.1815.2122* dereferenceable(32), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESG_mEES4_T0_T1_RNS1_IT2_NS2_ISJ_EEEEmmmmEUlmE1_EEmOT_NS4_18_from_function_tagEmEUlmE_EEvmmSO_mb(i64, i64, %class.anon.248.281.588.895.1202.1509.1816.2123* byval(%class.anon.248.281.588.895.1202.1509.1816.2123) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"* @_ZN8oct_treeI6vertexI7point2dIdEEE4node8new_nodeEPS5_S6_(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN8oct_treeI6vertexI7point2dIdEEE4nodeC2EN6parlay5sliceIPSt4pairImPS3_ESB_EE(%"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*, %"struct.std::pair.149.202.511.818.1125.1432.1739.2046"*) unnamed_addr #4 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEED2Ev(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"*) unnamed_addr #8 align 2

; Function Attrs: nounwind sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPcED2Ev(%"class.parlay::concurrent_stack.28.339.646.953.1260.1567.1874"*) unnamed_addr #8 align 2

declare dso_local i32 @__cilkrts_get_nworkers() local_unnamed_addr #0

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_15block_allocator7reserveEmEUlmE_EEvmmT_mb(i64, i64, i8**, %"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPNS_15block_allocator5blockEE5clearEv(%"class.parlay::concurrent_stack.74.32.343.650.957.1264.1571.1878"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay16concurrent_stackIPcE5clearEv(%"class.parlay::concurrent_stack.28.339.646.953.1260.1567.1874"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local zeroext i1 @_ZN6parlay15block_allocator5clearEv(%"struct.parlay::block_allocator.36.347.654.961.1268.1575.1882"*) local_unnamed_addr #4 align 2

; Function Attrs: sanitize_cilk uwtable
declare dso_local { i8*, i8 } @_ZN6parlay16concurrent_stackIPcE3popEv(%"class.parlay::concurrent_stack.28.339.646.953.1260.1567.1874"*) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEE16initialize_rangeIPS6_EEvT_SC_St26random_access_iterator_tagEUlmE_EEvmmSC_mb(i64, i64, %class.anon.262.282.589.896.1203.1510.1817.2124* byval(%class.anon.262.282.589.896.1203.1510.1817.2124) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN19k_nearest_neighborsI6vertexI7point2dIdEELi1EE3kNN13k_nearest_recEPN8oct_treeIS3_E4nodeE(%"struct.k_nearest_neighbors<vertex<point2d<double> >, 1>::kNN.283.590.897.1204.1511.1818.2125"*, %"struct.oct_tree<vertex<point2d<double> > >::node.110.421.728.1035.1342.1649.1956"*) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_8pack_outINS_5sliceIPP6vertexI7point2dIdEESA_EENS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIS9_NS_9allocatorIS9_EEEES9_E3$_6EESB_EEmRKT_RKT0_T1_jEUlmmmE_EEvmmSL_jEUlmE_EEvmmSJ_mb"(i64, i64, i64*, i64*, %class.anon.264.286.593.900.1207.1514.1821.2128*) unnamed_addr #5

; Function Attrs: inlinehint nounwind sanitize_cilk uwtable
declare dso_local fastcc void @"_ZN6parlay12parallel_forIZNS_8internal10sliced_forIZNS1_8pack_outINS_5sliceIPP6vertexI7point2dIdEESA_EENS_16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIS9_NS_9allocatorIS9_EEEES9_E3$_6EESB_EEmRKT_RKT0_T1_jEUlmmmE0_EEvmmSL_jEUlmE_EEvmmSJ_mb"(i64, i64, i64*, i64*, %class.anon.265.287.594.901.1208.1515.1822.2129*) unnamed_addr #5

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceI8triangleI7point2dIdEENS_9allocatorIS4_EEE18initialize_defaultEm(%"class.parlay::sequence.72.383.690.997.1304.1611.1918"*, i64) local_unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceI8triangleI7point2dIdEENS_9allocatorIS5_EEE18initialize_defaultEmEUlmE_EEvmmT_mb(i64, i64, %"class.parlay::sequence.72.383.690.997.1304.1611.1918"*, %struct.triangle.53.364.671.978.1285.1592.1899**, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14random_shuffleINS_8sequenceImNS_9allocatorImEEEEEEDaRKT_NS_6randomE(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* noalias sret, %"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* dereferenceable(15), i64) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8sequenceImNS_9allocatorImEEEC2IZNS_18random_permutationImEENS0_IT_NS1_IS6_EEEEmNS_6randomEEUlmE_EEmOS6_NS3_18_from_function_tagEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"*, i64, %class.anon.270.288.595.902.1209.1516.1823.2130* dereferenceable(1), i64) unnamed_addr #4 align 2

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8sequenceImNS_9allocatorImEEEC1IZNS_18random_permutationImEENS1_IT_NS2_IS7_EEEEmNS_6randomEEUlmE_EEmOS7_NS4_18_from_function_tagEmEUlmE_EEvmmS7_mb(i64, i64, %class.anon.272.289.596.903.1210.1517.1824.2131* byval(%class.anon.272.289.596.903.1210.1517.1824.2131) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal15random_shuffle_IPKmPmEEvNS_5sliceIT_S6_EENS5_IT0_S8_EENS_6randomE(i64*, i64*, i64*, i64*, i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal15random_shuffle_IPKmPmEEvNS_5sliceIT_S7_EENS6_IT0_S9_EENS_6randomEEUlmE1_EEvmmS7_mb(i64, i64, %class.anon.285.291.598.905.1212.1519.1826.2133* byval(%class.anon.285.291.598.905.1212.1519.1826.2133) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal11count_sort_INS_22uninitialized_copy_tagEjPKmPmNS_16delayed_sequenceImZNS0_15random_shuffle_IS4_S5_EEvNS_5sliceIT_S9_EENS8_IT0_SB_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS8_IT1_SN_EENS8_IT2_SP_EENS8_IT3_SR_EEmfb(%"struct.std::pair.276.292.599.906.1213.1520.1827.2134"* noalias sret, i64*, i64*, i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i64, float, i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal11count_sort_INS_22uninitialized_copy_tagEmPKmPmNS_16delayed_sequenceImZNS0_15random_shuffle_IS4_S5_EEvNS_5sliceIT_S9_EENS8_IT0_SB_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS8_IT1_SN_EENS8_IT2_SP_EENS8_IT3_SR_EEmfb(%"struct.std::pair.276.292.599.906.1213.1520.1827.2134"* noalias sret, i64*, i64*, i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i64, float, i1 zeroext) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal14seq_count_sortINS_22uninitialized_copy_tagEPKmPmNS_16delayed_sequenceImZNS0_15random_shuffle_IS4_S5_EEvNS_5sliceIT_S9_EENS8_IT0_SB_EENS_6randomEEUlmE0_E8iteratorEEENS_8sequenceImNS_9allocatorImEEEESC_NS8_IT1_SL_EENS8_IT2_SN_EEm(%"class.parlay::sequence.9.81.392.699.1006.1313.1620.1927"* noalias sret, i64*, i64*, i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEjPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE_EEvmmSA_mb(i64, i64, %class.anon.286.297.604.911.1218.1525.1832.2139* byval(%class.anon.286.297.604.911.1218.1525.1832.2139) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEjPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE0_EEvmmSA_mb(i64, i64, %class.anon.287.298.605.912.1219.1526.1833.2140* byval(%class.anon.287.298.605.912.1219.1526.1833.2140) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEjPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE1_EEvmmSA_mb(i64, i64, %class.anon.288.299.606.913.1220.1527.1834.2141* byval(%class.anon.288.299.606.913.1220.1527.1834.2141) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEjPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE2_EEvmmSA_mb(i64, i64, %class.anon.289.300.607.914.1221.1528.1835.2142* byval(%class.anon.289.300.607.914.1221.1528.1835.2142) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEjPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE3_EEvmmSA_mb(i64, i64, %class.anon.290.301.608.915.1222.1529.1836.2143* byval(%class.anon.290.301.608.915.1222.1529.1836.2143) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: nounwind readnone speculatable willreturn
declare float @llvm.round.f32(float) #12

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal15seq_count_sort_INS_22uninitialized_copy_tagENS_5sliceIPKmS5_EENS3_IPmS7_EES7_NS3_INS_16delayed_sequenceImZNS0_15random_shuffle_IS5_S7_EEvNS3_IT_SB_EENS3_IT0_SD_EENS_6randomEEUlmE0_E8iteratorESI_EEEEvSD_T1_T3_T2_m(i64*, i64*, i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i64*, i64) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10seq_count_INS_5sliceIPKmS4_EEPmNS2_INS_16delayed_sequenceImZNS0_15random_shuffle_IS4_S6_EEvNS2_IT_S9_EENS2_IT0_SB_EENS_6randomEEUlmE0_E8iteratorESG_EEEEvS9_T1_SB_m(i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i64*, i64) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10seq_count_INS_5sliceIPKmS4_EEPjNS2_INS_16delayed_sequenceImZNS0_15random_shuffle_IS4_PmEEvNS2_IT_SA_EENS2_IT0_SC_EENS_6randomEEUlmE0_E8iteratorESH_EEEEvSA_T1_SC_m(i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i32*, i64) local_unnamed_addr #4

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10seq_write_INS_22uninitialized_copy_tagENS_5sliceIPKmS5_EEPmPjNS3_INS_16delayed_sequenceImZNS0_15random_shuffle_IS5_S7_EEvNS3_IT_SB_EENS3_IT0_SD_EENS_6randomEEUlmE0_E8iteratorESI_EEEEvSD_T1_T3_T2_m(i64*, i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i32*, i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEmPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE_EEvmmSA_mb(i64, i64, %class.anon.291.302.609.916.1223.1530.1837.2144* byval(%class.anon.291.302.609.916.1223.1530.1837.2144) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEmPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE0_EEvmmSA_mb(i64, i64, %class.anon.292.303.610.917.1224.1531.1838.2145* byval(%class.anon.292.303.610.917.1224.1531.1838.2145) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEmPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE1_EEvmmSA_mb(i64, i64, %class.anon.293.304.611.918.1225.1532.1839.2146* byval(%class.anon.293.304.611.918.1225.1532.1839.2146) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEmPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE2_EEvmmSA_mb(i64, i64, %class.anon.294.305.612.919.1226.1533.1840.2147* byval(%class.anon.294.305.612.919.1226.1533.1840.2147) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_8internal11count_sort_INS_22uninitialized_copy_tagEmPKmPmNS_16delayed_sequenceImZNS1_15random_shuffle_IS5_S6_EEvNS_5sliceIT_SA_EENS9_IT0_SC_EENS_6randomEEUlmE0_E8iteratorEEESt4pairINS_8sequenceImNS_9allocatorImEEEEbENS9_IT1_SO_EENS9_IT2_SQ_EENS9_IT3_SS_EEmfbEUlmE3_EEvmmSA_mb(i64, i64, %class.anon.295.306.613.920.1227.1534.1841.2148* byval(%class.anon.295.306.613.920.1227.1534.1841.2148) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay8internal10seq_write_INS_22uninitialized_copy_tagENS_5sliceIPKmS5_EEPmS7_NS3_INS_16delayed_sequenceImZNS0_15random_shuffle_IS5_S7_EEvNS3_IT_SA_EENS3_IT0_SC_EENS_6randomEEUlmE0_E8iteratorESH_EEEEvSC_T1_T3_T2_m(i64*, i64*, i64*, %"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138"* byval(%"struct.parlay::slice.279.296.603.910.1217.1524.1831.2138") align 8, i64*, i64) local_unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZZN6parlay8internal15random_shuffle_IPKmPmEEvNS_5sliceIT_S6_EENS5_IT0_S8_EENS_6randomEENKUlmE1_clEm(%class.anon.285.291.598.905.1212.1519.1826.2133*, i64) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_implC2ERKS9_(%"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl.106.417.724.1031.1338.1645.1952"*, %"struct.parlay::_sequence_base<vertex<point2d<double> > *, parlay::allocator<vertex<point2d<double> > *> >::_sequence_impl.106.417.724.1031.1338.1645.1952"* dereferenceable(15)) unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS6_EEE14_sequence_implC1ERKSA_EUlmE_EEvmmT_mb(i64, i64, %class.anon.296.307.614.921.1228.1535.1842.2149* byval(%class.anon.296.307.614.921.1228.1535.1842.2149) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14_sequence_baseI7point2dIdENS_9allocatorIS2_EEE14_sequence_implC2ERKS6_(%"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl.88.399.706.1013.1320.1627.1934"*, %"struct.parlay::_sequence_base<point2d<double>, parlay::allocator<point2d<double> > >::_sequence_impl.88.399.706.1013.1320.1627.1934"* dereferenceable(15)) unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_14_sequence_baseI7point2dIdENS_9allocatorIS3_EEE14_sequence_implC1ERKS7_EUlmE_EEvmmT_mb(i64, i64, %class.anon.297.308.615.922.1229.1536.1843.2150* byval(%class.anon.297.308.615.922.1229.1536.1843.2150) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: sanitize_cilk uwtable
declare dso_local void @_ZN6parlay14_sequence_baseISt5arrayIiLm3EENS_9allocatorIS2_EEE14_sequence_implC2ERKS6_(%"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl.143.454.761.1068.1375.1682.1989"*, %"struct.parlay::_sequence_base<std::array<int, 3>, parlay::allocator<std::array<int, 3> > >::_sequence_impl.143.454.761.1068.1375.1682.1989"* dereferenceable(15)) unnamed_addr #4

; Function Attrs: inlinehint sanitize_cilk uwtable
declare dso_local void @_ZN6parlay12parallel_forIZNS_14_sequence_baseISt5arrayIiLm3EENS_9allocatorIS3_EEE14_sequence_implC1ERKS7_EUlmE_EEvmmT_mb(i64, i64, %class.anon.298.310.617.924.1231.1538.1845.2152* byval(%class.anon.298.310.617.924.1231.1538.1845.2152) align 8, i64, i1 zeroext) local_unnamed_addr #6

; Function Attrs: nounwind readnone speculatable willreturn
declare i64 @llvm.ctlz.i64(i64, i1 immarg) #12

; Function Attrs: argmemonly willreturn
declare void @llvm.detached.rethrow.sl_p0i8i32s(token, { i8*, i32 }) #14

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.taskframe.end(token) #3

; Function Attrs: argmemonly willreturn
declare void @llvm.taskframe.resume.sl_p0i8i32s(token, { i8*, i32 }) #14

attributes #0 = { "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #1 = { nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #2 = { nofree nounwind }
attributes #3 = { argmemonly nounwind willreturn }
attributes #4 = { sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #5 = { inlinehint nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #6 = { inlinehint sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #7 = { nofree nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #8 = { nounwind sanitize_cilk uwtable "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "min-legal-vector-width"="0" "no-infs-fp-math"="false" "no-jump-tables"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #9 = { noreturn "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #10 = { noinline noreturn nounwind }
attributes #11 = { nobuiltin nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #12 = { nounwind readnone speculatable willreturn }
attributes #13 = { nobuiltin nofree "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #14 = { argmemonly willreturn }
attributes #15 = { noreturn nounwind "correctly-rounded-divide-sqrt-fp-math"="false" "disable-tail-calls"="false" "frame-pointer"="none" "less-precise-fpmad"="false" "no-infs-fp-math"="false" "no-nans-fp-math"="false" "no-signed-zeros-fp-math"="false" "no-trapping-math"="false" "stack-protector-buffer-size"="8" "target-cpu"="x86-64" "target-features"="+cx16,+cx8,+fxsr,+mmx,+sse,+sse2,+x87" "unsafe-fp-math"="false" "use-soft-float"="false" }
attributes #16 = { nounwind }
attributes #17 = { noreturn nounwind }

!llvm.module.flags = !{!0}
!llvm.ident = !{!1}

!0 = !{i32 1, !"wchar_size", i32 4}
!1 = !{!"clang version 10.0.1 (git@github.com:OpenCilk/opencilk-project.git fffc5516029927e6f93460fb66ad35b34f9b0b9b)"}
!2 = !{!3, !4, i64 0}
!3 = !{!"_ZTSN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!4 = !{!"any pointer", !5, i64 0}
!5 = !{!"omnipotent char", !6, i64 0}
!6 = !{!"Simple C++ TBAA"}
!7 = !{!8, !9, i64 0}
!8 = !{!"_ZTSN6parlay14_sequence_baseIP6vertexI7point2dIdEENS_9allocatorIS5_EEE14_sequence_impl18capacitated_buffer6headerE", !9, i64 0, !5, i64 8}
!9 = !{!"long", !5, i64 0}
!10 = !{!11, !9, i64 0}
!11 = !{!"_ZTSN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl18capacitated_buffer6headerE", !9, i64 0, !5, i64 8}
!12 = !{i64 0, i64 8, !13, i64 8, i64 8, !14}
!13 = !{!4, !4, i64 0}
!14 = !{!9, !9, i64 0}
!15 = !{!16, !4, i64 0}
!16 = !{!"_ZTS7simplexI7point2dIdEE", !4, i64 0, !17, i64 8, !18, i64 12}
!17 = !{!"int", !5, i64 0}
!18 = !{!"bool", !5, i64 0}
!19 = !{!16, !17, i64 8}
!20 = !{!16, !18, i64 12}
!21 = distinct !{!21, !22}
!22 = !{!"llvm.loop.from.tapir.loop"}
!23 = distinct !{!23, !24, !25}
!24 = !{!"tapir.loop.spawn.strategy", i32 1}
!25 = !{!"tapir.loop.grainsize", i32 1}
!26 = distinct !{!26, !22}
!27 = !{!28, !4, i64 0}
!28 = !{!"_ZTSN6parlay14_sequence_baseI7simplexI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!29 = !{!30, !4, i64 0}
!30 = !{!"_ZTSN6parlay14_sequence_baseIbNS_9allocatorIbEEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!31 = !{!32, !9, i64 0}
!32 = !{!"_ZTSN6parlay14_sequence_baseIbNS_9allocatorIbEEE14_sequence_impl18capacitated_buffer6headerE", !9, i64 0, !5, i64 8}
!33 = !{!34, !36}
!34 = distinct !{!34, !35, !"_ZN6parlay8sequenceI2QsI7point2dIdEENS_9allocatorIS4_EEE13from_functionIRZ24incrementally_add_pointsNS0_IP6vertexIS3_ENS5_ISB_EEEESB_E3$_3EES7_mOT_m: %agg.result"}
!35 = distinct !{!35, !"_ZN6parlay8sequenceI2QsI7point2dIdEENS_9allocatorIS4_EEE13from_functionIRZ24incrementally_add_pointsNS0_IP6vertexIS3_ENS5_ISB_EEEESB_E3$_3EES7_mOT_m"}
!36 = distinct !{!36, !37, !"_ZN6parlay8internal8tabulateIZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_3EEDamOT_m: %agg.result"}
!37 = distinct !{!37, !"_ZN6parlay8internal8tabulateIZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS7_EEEES7_E3$_3EEDamOT_m"}
!38 = !{!39, !9, i64 0}
!39 = !{!"_ZTSN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl18capacitated_buffer6headerE", !9, i64 0, !5, i64 8}
!40 = !{!41, !4, i64 0}
!41 = !{!"_ZTSN6parlay14_sequence_baseI2QsI7point2dIdEENS_9allocatorIS4_EEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!42 = !{!43, !4, i64 0}
!43 = !{!"_ZTSNSt12_Vector_baseI7simplexI7point2dIdEESaIS3_EE17_Vector_impl_dataE", !4, i64 0, !4, i64 8, !4, i64 16}
!44 = !{!45, !4, i64 0}
!45 = !{!"_ZTSNSt12_Vector_baseIP6vertexI7point2dIdEESaIS4_EE17_Vector_impl_dataE", !4, i64 0, !4, i64 8, !4, i64 16}
!46 = distinct !{!46, !22}
!47 = distinct !{!47, !24, !25}
!48 = distinct !{!48, !22}
!49 = !{!50, !4, i64 0}
!50 = !{!"_ZTSSt10_Head_baseILm0EPN8oct_treeI6vertexI7point2dIdEEE4nodeELb0EE", !4, i64 0}
!51 = !{!52}
!52 = distinct !{!52, !53, !"_ZN6parlay11to_sequenceINS_5sliceIPP6vertexI7point2dIdEES7_EEEENS_8sequenceINS_16range_value_typeIT_E4typeENS_9allocatorISD_EEEEOSB_: %agg.result"}
!53 = distinct !{!53, !"_ZN6parlay11to_sequenceINS_5sliceIPP6vertexI7point2dIdEES7_EEEENS_8sequenceINS_16range_value_typeIT_E4typeENS_9allocatorISD_EEEEOSB_"}
!54 = !{!55, !4, i64 0}
!55 = !{!"_ZTSZN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEE16initialize_rangeIPS5_EEvT_SB_St26random_access_iterator_tagEUlmE_", !4, i64 0, !4, i64 8, !4, i64 16}
!56 = !{i64 0, i64 8, !13, i64 8, i64 4, !57, i64 12, i64 1, !58}
!57 = !{!17, !17, i64 0}
!58 = !{!18, !18, i64 0}
!59 = distinct !{!59, !24}
!60 = !{!61}
!61 = distinct !{!61, !62, !"_ZN6parlay4packINS_5sliceIPP6vertexI7point2dIdEES7_EENS1_IPbS9_EEEEDaRKT_RKT0_: %agg.result"}
!62 = distinct !{!62, !"_ZN6parlay4packINS_5sliceIPP6vertexI7point2dIdEES7_EENS1_IPbS9_EEEEDaRKT_RKT0_"}
!63 = !{!64, !9, i64 0}
!64 = !{!"_ZTSN6parlay16delayed_sequenceIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEEES6_E3$_6EE", !9, i64 0, !9, i64 8, !65, i64 16}
!65 = !{!"_ZTSZ24incrementally_add_pointsN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEES5_E3$_6", !4, i64 0}
!66 = !{!67}
!67 = distinct !{!67, !68, !"_ZN6parlay11delayed_seqIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEEES6_E3$_6EENS_16delayed_sequenceIT_T0_EEmSD_: %agg.result"}
!68 = distinct !{!68, !"_ZN6parlay11delayed_seqIbZ24incrementally_add_pointsNS_8sequenceIP6vertexI7point2dIdEENS_9allocatorIS6_EEEES6_E3$_6EENS_16delayed_sequenceIT_T0_EEmSD_"}
!69 = !{!64, !9, i64 8}
!70 = !{i8 0, i8 2}
!71 = !{!65, !4, i64 0}
!72 = !{!73, !4, i64 0}
!73 = !{!"_ZTSN6parlay14_sequence_baseImNS_9allocatorImEEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!74 = !{!75, !9, i64 0}
!75 = !{!"_ZTSN6parlay14_sequence_baseImNS_9allocatorImEEE14_sequence_impl18capacitated_buffer6headerE", !9, i64 0, !5, i64 8}
!76 = distinct !{!76, !22}
!77 = distinct !{!77, !24, !25}
!78 = distinct !{!78, !22}
!79 = distinct !{!79, !22}
!80 = distinct !{!80, !24, !25}
!81 = distinct !{!81, !22}
!82 = !{!83, !9, i64 0}
!83 = !{!"_ZTSN8oct_treeI6vertexI7point2dIdEEE4nodeE", !9, i64 0, !4, i64 8, !4, i64 16, !4, i64 24, !84, i64 32, !85, i64 64, !87, i64 80}
!84 = !{!"_ZTSSt4pairI7point2dIdES1_E", !85, i64 0, !85, i64 16}
!85 = !{!"_ZTS7point2dIdE", !86, i64 0, !86, i64 8}
!86 = !{!"double", !5, i64 0}
!87 = !{!"_ZTSN6parlay8sequenceIP6vertexI7point2dIdEENS_9allocatorIS5_EEEE"}
!88 = !{!83, !4, i64 24}
!89 = !{!90, !4, i64 320}
!90 = !{!"_ZTSN6parlay15block_allocatorE", !18, i64 0, !91, i64 64, !94, i64 192, !4, i64 320, !9, i64 328, !9, i64 336, !9, i64 344, !96, i64 352, !9, i64 360}
!91 = !{!"_ZTSN6parlay16concurrent_stackIPcEE", !92, i64 0, !92, i64 64}
!92 = !{!"_ZTSN6parlay16concurrent_stackIPcE24locking_concurrent_stackE", !4, i64 0, !93, i64 8}
!93 = !{!"_ZTSSt5mutex"}
!94 = !{!"_ZTSN6parlay16concurrent_stackIPNS_15block_allocator5blockEEE", !95, i64 0, !95, i64 64}
!95 = !{!"_ZTSN6parlay16concurrent_stackIPNS_15block_allocator5blockEE24locking_concurrent_stackE", !4, i64 0, !93, i64 8}
!96 = !{!"_ZTSSt6atomicImE"}
!97 = !{!98, !9, i64 0}
!98 = !{!"_ZTSN6parlay15block_allocator11thread_listE", !9, i64 0, !4, i64 8, !4, i64 16, !5, i64 24}
!99 = !{!90, !9, i64 328}
!100 = !{!98, !4, i64 8}
!101 = !{!98, !4, i64 16}
!102 = !{!103, !4, i64 0}
!103 = !{!"_ZTSN6parlay15block_allocator5blockE", !4, i64 0}
!104 = !{!83, !4, i64 16}
!105 = !{!106, !4, i64 0}
!106 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEE12_Alloc_hiderE", !4, i64 0}
!107 = !{!108, !9, i64 8}
!108 = !{!"_ZTSNSt7__cxx1112basic_stringIcSt11char_traitsIcESaIcEEE", !106, i64 0, !9, i64 8, !5, i64 16}
!109 = !{!5, !5, i64 0}
!110 = !{!111, !86, i64 0}
!111 = !{!"_ZTS5timer", !86, i64 0, !86, i64 8, !18, i64 16, !108, i64 24, !112, i64 56}
!112 = !{!"_ZTS8timezone", !17, i64 0, !17, i64 4}
!113 = !{!111, !18, i64 16}
!114 = !{!112, !17, i64 0}
!115 = !{!112, !17, i64 4}
!116 = !{!108, !4, i64 0}
!117 = !{!118, !4, i64 0}
!118 = !{!"_ZTSN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!119 = !{!120, !9, i64 0}
!120 = !{!"_ZTSN6parlay14_sequence_baseISt4pairImP6vertexI7point2dIdEEENS_9allocatorIS7_EEE14_sequence_impl18capacitated_buffer6headerE", !9, i64 0, !5, i64 8}
!121 = !{!122, !4, i64 8}
!122 = !{!"_ZTSZN6parlay8sequenceImNS_9allocatorImEEEC1IZNS_8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESF_jEES3_T0_T1_RNS0_IT2_NS1_ISI_EEEEmmmmEUlmE1_EEmOT_NS3_18_from_function_tagEmEUlmE_", !4, i64 0, !4, i64 8, !4, i64 16}
!123 = !{!122, !4, i64 16}
!124 = !{!125, !4, i64 0}
!125 = !{!"_ZTSZN6parlay8internal17transpose_bucketsINS_26uninitialized_relocate_tagEPSt4pairImP6vertexI7point2dIdEEESA_jEENS_8sequenceImNS_9allocatorImEEEET0_T1_RNSB_IT2_NSC_ISH_EEEEmmmmEUlmE1_", !4, i64 0, !4, i64 8, !4, i64 16, !4, i64 24}
!126 = !{!125, !4, i64 8}
!127 = !{!125, !4, i64 16}
!128 = !{!125, !4, i64 24}
!129 = !{!130, !4, i64 0}
!130 = !{!"_ZTSN6parlay14_sequence_baseIjNS_9allocatorIjEEE14_sequence_impl18capacitated_bufferE", !4, i64 0}
!131 = distinct !{!131, !22}
!132 = distinct !{!132, !24, !25}
!133 = distinct !{!133, !22}
!134 = !{i64 0, i64 8, !13, i64 8, i64 8, !13, i64 16, i64 8, !13}
