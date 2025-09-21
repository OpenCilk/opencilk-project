Name:       opencilk
Version:    3.0
Release:    %{autorelease}
Summary:    Shared memory task parallelization tool

License:    Apache-2.0-WITH-LLVM-Exceptions AND MIT-WITH-OpenCilk-Addendum
URL:        htttps://www.opencilk.org
Source0:    https://github.com/OpenCilk/opencilk-project/archive/opencilk/v%{version}/opencilk-project-%{version}.tar.gz
Source1:    https://github.com/OpenCilk/cheetah/archive/opencilk/v%{version}/cheetah-%{version}.tar.gz
Source2:    https://github.com/OpenCilk/productivity-tools/archive/opencilk/v%{version}/productivity-tools-%{version}.tar.gz
Patch:      linux-termios.patch

BuildRequires:  cmake
BuildRequires:  gcc
BuildRequires:  gcc-c++
BuildRequires:  ninja-build
BuildRequires:  git

%description
OpenCilk is a state-of-the-art open-source implementation of the Cilk
task-parallel programming platform. OpenCilk supports writing fast parallel
programs using the Cilk task-parallel language extensions to C/C++. In
addition, OpenCilk provides a platform to develop compilers, runtime systems,
and program-analysis tools for task-parallel code.

%prep
%autosetup -p1 -n opencilk-project-opencilk-v%{version}
tar -xf %{SOURCE1}
mv cheetah-opencilk-v%{version} cheetah
tar -xf %{SOURCE2}
mv productivity-tools-opencilk-v%{version} cilktools

%build
%cmake -DLLVM_ENABLE_PROJECTS="clang;compiler-rt" \
       -DLLVM_ENABLE_RUNTIMES="cheetah;cilktools" \
       -DLLVM_ENABLE_ASSERTIONS="ON" \
       -DLLVM_TARGETS_TO_BUILD="host" \
       -DLLVM_OPTIMIZED_TABLEGEN=On \
       -DCMAKE_BUILD_TYPE=RelWithDebInfo \
       -G Ninja \
       -S llvm \
       -B  %_vpath_builddir
%cmake_build


%install
%cmake_install


%files
%license LICENSE.txt
%license MIT_LICENSE.txt
%doc README.md
%doc README_LLVM.md
%{_includedir}/clang/
%{_includedir}/clang-c/
%{_includedir}/llvm/
%{_includedir}/llvm-c/
%{_libdir}/libclang*
%{_libdir}/libLLVM*
%{_libdir}/clang/
%{_libdir}/cmake/clang/
%{_libdir}/cmake/llvm
%{_libdir}/libear/
%{_libdir}/libscanbuild/
%{_libdir}/libLTO.so
%{_libdir}/libLTO.so.16
%{_libdir}/libRemarks.so
%{_libdir}/libRemarks.so.16
%{_bindir}/amdgpu-arch
%{_bindir}/analyze-build
%{_bindir}/bugpoint
%{_bindir}/c-index-test
%{_bindir}/clang*
%{_bindir}/diagtool
%{_bindir}/dsymutil
%{_bindir}/git-clang-format
%{_bindir}/hmaptool
%{_bindir}/intercept-build
%{_bindir}/llc
%{_bindir}/lli
%{_bindir}/llvm*
%{_bindir}/nvptx-arch
%{_bindir}/opt
%{_bindir}/sancov
%{_bindir}/sanstats
%{_bindir}/scan-build
%{_bindir}/scan-build-py
%{_bindir}/scan-view
%{_bindir}/verify-uselistorder

%changelog
%autochangelog
