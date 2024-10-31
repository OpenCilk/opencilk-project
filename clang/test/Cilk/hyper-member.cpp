// RUN: %clang_cc1 %s -x c++ -triple aarch64-freebsd -fopencilk -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
struct ctor_dtor { ctor_dtor(); ~ctor_dtor(); long data; };
struct ctor_only { ctor_only(); long data; };
struct dtor_only { ~dtor_only(); long data; };
struct neither { long data; };
extern void identity(void *), reduce(void *, void *);
struct with_ctor_dtor {
  with_ctor_dtor();
  ~with_ctor_dtor();
  ctor_dtor _Hyperobject(identity, reduce) field;
};

// Hyperobject field is constructed then registered.
// CHECK-LABEL: _ZN14with_ctor_dtorC2Ev
// CHECK: call void @_ZN9ctor_dtorC1Ev
// CHECK: call void @llvm.reducer.register
with_ctor_dtor::with_ctor_dtor() { }

// Hyperobject field is destructed then unregistered.
// CHECK-LABEL: _ZN14with_ctor_dtorD2Ev
// CHECK: call void @llvm.reducer.unregister
// CHECK: call void @_ZN9ctor_dtorD1Ev
with_ctor_dtor::~with_ctor_dtor() { }

template<class Field> struct wrapper {
  wrapper();
  ~wrapper();
  Field field;
};

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH9ctor_dtorEC2Ev
// CHECK: call void @_ZN9ctor_dtorC1Ev
// CHECK: call void @llvm.reducer.register
template<> wrapper<ctor_dtor _Hyperobject(identity, reduce)>::wrapper() { }
// CHECK-LABEL: define dso_local void @_ZN7wrapperIH9ctor_dtorED2Ev
// CHECK: call void @llvm.reducer.unregister
// CHECK: call void @_ZN9ctor_dtorD1Ev
template<> wrapper<ctor_dtor _Hyperobject(identity, reduce)>::~wrapper() { }

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH9ctor_onlyEC2Ev
// CHECK: call void @_ZN9ctor_onlyC1Ev
// CHECK: call void @llvm.reducer.register
template<> wrapper<ctor_only _Hyperobject(identity, reduce)>::wrapper() { }

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH9ctor_onlyED2Ev
// CHECK: call void @llvm.reducer.unregister
// CHECK-NOT: call void @_ZN9ctor_onlyD1Ev
template<> wrapper<ctor_only _Hyperobject(identity, reduce)>::~wrapper() { }

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH9dtor_onlyEC2Ev
// CHECK-NOT: call void @_ZN9dtor_onlyC1Ev
// CHECK:   call void @llvm.reducer.register
template<> wrapper<dtor_only _Hyperobject(identity, reduce)>::wrapper() { }

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH9dtor_onlyED2Ev
// CHECK: call void @llvm.reducer.unregister
// CHECK: call void @_ZN9dtor_onlyD1Ev
template<> wrapper<dtor_only _Hyperobject(identity, reduce)>::~wrapper() { }

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH7neitherEC2Ev
// CHECK-NOT: call void @_ZN7neitherC1Ev
// CHECK: call void @llvm.reducer.register
template<> wrapper<neither _Hyperobject(identity, reduce)>::wrapper() { }

// CHECK-LABEL: define dso_local void @_ZN7wrapperIH7neitherED2Ev
// CHECK:  call void @llvm.reducer.unregister
// CHECK-NOT: call void @_ZN7neitherD1Ev
template<> wrapper<neither _Hyperobject(identity, reduce)>::~wrapper() { }
