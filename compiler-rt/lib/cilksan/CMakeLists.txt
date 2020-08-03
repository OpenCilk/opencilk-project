# Build for the Cilksan runtime support library.

set(CILKSAN_SOURCES
  cilksan.cpp
  debug_util.cpp
  print_addr.cpp
  drivercsan.cpp
  csanrt.cpp)
  # mem_access.cpp
  # compresseddict_shadow_mem.cpp
  # shadow_mem.cpp
  # static_dictionary.cpp

include_directories(${COMPILER_RT_SOURCE_DIR}/include)

set(CILKSAN_CFLAGS ${SANITIZER_COMMON_CFLAGS})
append_list_if(COMPILER_RT_HAS_STD_CXX11_FLAG -std=c++11 CILKSAN_CFLAGS)
append_list_if(COMPILER_RT_HAS_FNO_EXCEPTIONS_FLAG -fno-exceptions CILKSAN_CFLAGS)
append_rtti_flag(OFF CILKSAN_CFLAGS)

set(CILKSAN_DYNAMIC_DEFINITIONS
  ${CILKSAN_COMMON_DEFINITIONS} CILKSAN_DYNAMIC=1)

set(CILKSAN_DYNAMIC_CFLAGS ${CILKSAN_CFLAGS})

set(CILKSAN_COMMON_LIBS ${SANITIZER_CXX_ABI_LIBRARY} ${SANITIZER_COMMON_LINK_LIBS})
# append_list_if(COMPILER_RT_HAS_SNAPPY snappy CILKSAN_COMMON_LIBS)

set(CILKSAN_DYNAMIC_LIBS ${CILKSAN_COMMON_LIBS})
#append_list_if(COMPILER_RT_HAS_LIBC c CILKSAN_DYNAMIC_LIBS)
append_list_if(COMPILER_RT_HAS_LIBDL dl CILKSAN_DYNAMIC_LIBS)
#append_list_if(COMPILER_RT_HAS_LIBRT rt CILKSAN_DYNAMIC_LIBS)
#append_list_if(COMPILER_RT_HAS_LIBM m CILKSAN_DYNAMIC_LIBS)
#append_list_if(COMPILER_RT_HAS_LIBPTHREAD pthread CILKSAN_DYNAMIC_LIBS)
#append_list_if(COMPILER_RT_HAS_LIBSTDCXX stdc++ CILKSAN_DYNAMIC_LIBS)
#append_list_if(COMPILER_RT_HAS_LIBLOG log CILKSAN_DYNAMIC_LIBS)

set(CILKSAN_COMMON_LINK_FLAGS)
append_list_if(COMPILER_RT_HAS_CILK_FLAG -fopencilk CILKSAN_COMMON_LINK_FLAGS)

set(CILKSAN_STATIC_LINK_FLAGS ${CILKSAN_COMMON_LINK_FLAGS})
append_list_if(COMPILER_RT_HAS_CILK_FLAG  -Wl,--wrap,merge_two_rmaps CILKSAN_STATIC_LINK_FLAGS)

set(CILKSAN_DYNAMIC_LINK_FLAGS ${CILKSAN_COMMON_LINK_FLAGS})

# Build Cilksan runtimes shipped with Clang.
add_compiler_rt_component(cilksan)

if (APPLE)
  # Compile Cilksan sources into an object library
  add_compiler_rt_object_libraries(RTCilksan_dynamic
    OS ${CILKTOOL_SUPPORTED_OS}
    ARCHS ${CILKSAN_SUPPORTED_ARCH}
    SOURCES ${CILKSAN_SOURCES}
    CFLAGS ${CILKSAN_DYNAMIC_CFLAGS}
    DEFS ${CILKSAN_DYNAMIC_DEFINITIONS})

  add_compiler_rt_object_libraries(RTCilksan
    OS ${CILKTOOL_SUPPORTED_OS}
    ARCHS ${CILKSAN_SUPPORTED_ARCH}
    SOURCES ${CILKSAN_SOURCES}
    CFLAGS ${CILKSAN_CFLAGS}
    DEFS ${CILKSAN_COMMON_DEFINITIONS})

  add_compiler_rt_runtime(clang_rt.cilksan
    STATIC
    OS ${CILKTOOL_SUPPORTED_OS}
    ARCHS ${CILKSAN_SUPPORTED_ARCH}
    OBJECT_LIBS RTCilksan
    CFLAGS ${CILKSAN_CFLAGS}
    LINK_FLAGS ${CILKSAN_STATIC_LINK_FLAGS}
    DEFS ${CILKSAN_COMMON_DEFINITIONS}
    PARENT_TARGET cilksan)

  add_compiler_rt_runtime(clang_rt.cilksan
    SHARED
    OS ${CILKTOOL_SUPPORTED_OS}
    ARCHS ${CILKSAN_SUPPORTED_ARCH}
    OBJECT_LIBS RTCilksan_dynamic
    CFLAGS ${CILKSAN_DYNAMIC_CFLAGS}
    LINK_FLAGS ${CILKSAN_DYNAMIC_LINK_FLAGS}
    LINK_LIBS ${CILKSAN_DYNAMIC_LIBS}
    DEFS ${CILKSAN_DYNAMIC_DEFINITIONS}
    PARENT_TARGET cilksan)

else() # Not APPLE
  # Compile Cilksan sources into an object library
  add_compiler_rt_object_libraries(RTCilksan_dynamic
    ARCHS ${CILKSAN_SUPPORTED_ARCH}
    SOURCES ${CILKSAN_SOURCES}
    CFLAGS ${CILKSAN_DYNAMIC_CFLAGS}
    DEFS ${CILKSAN_DYNAMIC_DEFINITIONS})

  add_compiler_rt_object_libraries(RTCilksan
    ARCHS ${CILKSAN_SUPPORTED_ARCH}
    SOURCES ${CILKSAN_SOURCES}
    CFLAGS ${CILKSAN_CFLAGS}
    DEFS ${CILKSAN_COMMON_DEFINITIONS})

  foreach (arch ${CILKSAN_SUPPORTED_ARCH})
    add_compiler_rt_runtime(clang_rt.cilksan
      STATIC
      ARCHS ${arch}
      OBJECT_LIBS RTCilksan
      CFLAGS ${CILKSAN_CFLAGS}
      LINK_FLAGS ${CILKSAN_STATIC_LINK_FLAGS}
      DEFS ${CILKSAN_COMMON_DEFINITIONS}
      PARENT_TARGET cilksan)

    add_compiler_rt_runtime(clang_rt.cilksan
      SHARED
      ARCHS ${arch}
      OBJECT_LIBS RTCilksan_dynamic
      CFLAGS ${CILKSAN_DYNAMIC_CFLAGS}
      LINK_FLAGS ${CILKSAN_DYNAMIC_LINK_FLAGS}
      LINK_LIBS ${CILKSAN_DYNAMIC_LIBS}
      DEFS ${CILKSAN_DYNAMIC_DEFINITIONS}
      PARENT_TARGET cilksan)
  endforeach()
endif()

if (COMPILER_RT_INCLUDE_TESTS)
  # TODO(bruening): add tests via add_subdirectory(tests)
endif()
