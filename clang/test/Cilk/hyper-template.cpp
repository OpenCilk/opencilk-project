// RUN: %clang_cc1 %s -fopencilk -verify -ftapir=none -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics

struct Base {
  virtual void identity(void *);
  virtual void reduce(void *, void *);
};

extern "C" Base *__hyper_lookup_class(struct Base *);

template<typename T> struct S : public Base {
  T member;
};

template<typename T> struct V : virtual public Base {
  T member;
};

S<long> _Hyperobject S_long;
V<long> _Hyperobject V_long;

// CHECK-LABEL: @_Z2fsv
// CHECK: %0 = call ptr @llvm.hyper.lookup.0(ptr @S_long)
// CHECK-NOT: call ptr @llvm.hyper.lookup
// CHECK: getelementptr
// CHECK: %[[RET:.+]] = load i64
// CHECK: ret i64 %[[RET]]
long fs() { return S_long.member; }

// CHECK-LABEL: @_Z2fvv
// CHECK: %0 = call ptr @llvm.hyper.lookup.0(ptr %cast.result)
long fv() { return V_long.member; }

// CHECK-LABEL: _Z2gsPH1SIsE
// CHECK: call ptr @llvm.hyper.lookup.0
// CHECK-NOT: call ptr @llvm.hyper.lookup
// CHECK: getelementptr
// CHECK: load i16
long gs(S<short> _Hyperobject *p) { return p->member; }

// CHECK-LABEL: _Z2gvPH1VIsE
// CHECK: call ptr @llvm.hyper.lookup.0(ptr %cast.result)
// CHECK-NOT: call ptr @llvm.hyper.lookup
// CHECK: getelementptr
// CHECK: load i16
long gv(V<short> _Hyperobject *p) { return p->member; }
