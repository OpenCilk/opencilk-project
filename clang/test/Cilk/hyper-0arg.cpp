// RUN: %clang_cc1 %s --std=c++20 -x c++ -fopencilk -verify -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

extern void* operator new(unsigned long size, void *ptr);

struct __reducer_base {
  virtual ~__reducer_base() { }
  // TODO: Should size be a data member?
  virtual unsigned long size() = 0;
  virtual void identity(void *view) = 0;
  virtual void reduce(__reducer_base *l, __reducer_base *r) = 0;
};

extern "C" __reducer_base *__hyper_lookup_class(__reducer_base *)
  __attribute__((nonnull, returns_nonnull));

struct Pad { int space[10]; };

struct R : protected Pad, public __reducer_base {
  static int global;
  int field;
  int &reference = global;
  void identity(void *view) override
    __attribute__((nonnull));
  void reduce(__reducer_base *l, __reducer_base *r) override
    __attribute__((nonnull));
  unsigned long size() override;
};

void R::identity(void *view)
{
  ::new (view) (R);
}

void R::reduce(__reducer_base *l, __reducer_base *r)
{
  static_cast<R *>(l)->field *= static_cast<R *>(r)->field;
}

unsigned long R::size()
{
  return sizeof *this;
}

struct R cilk_reducer r;
// CHECK-LABEL: @_Z8lookup_rv
int lookup_r()
{
  // CHECK: call ptr @llvm.hyper.lookup.0
  // CHECK-NOT: dynamic_cast
  // CHECK: ret i32
  return r.field;
}

// Virtual base class.
struct Distant : virtual __reducer_base, protected Pad
{
  long field;
  virtual void identity(void *view) override;
  virtual void reduce(__reducer_base *l, __reducer_base *r) override;
  unsigned long size() override { return sizeof *this; }
};
struct Distant cilk_reducer d;
// CHECK-LABEL: @_Z8lookup_dv
long lookup_d()
{
  // Currently the clang 19 front end generates an if (false) test
  // checking for a null pointer.  The value %cast.result is a PHI
  // of the unreachable block and the original pointer.
  // Returning a reference from __hyper_lookup_class would eliminate
  // the test (seeCodeGenFunction::ShouldNullCheckClassCastValue)
  // but triggers assertions in AST code.
  // CHECK: call ptr @llvm.hyper.lookup.0(ptr %cast.result)
  return d.field;
}

// CHECK-LABEL: @_Z12lookup_d_ptrPH7Distant
long lookup_d_ptr(struct Distant cilk_reducer *d)
{
  // CHECK: call ptr @llvm.hyper.lookup.0(ptr %cast.result)
  // CHECK: dynamic_cast
  return d->field;
}

// Make sure rvalue references to reducers don't cause errors.
// CHECK-LABEL: pass_reference
Distant cilk_reducer &&pass_reference(Distant cilk_reducer &ref)
{
  // CHECK: %ref.addr = alloca ptr, align 8
  // CHECK: store ptr %ref, ptr %ref.addr
  // This is hand-coded std::move.  In this context it copies the address
  // unchanged.
  return static_cast<Distant cilk_reducer &&>(ref);
  // CHECK: %0 = load ptr, ptr %ref.addr
  // CHECK: ret ptr %0
}
