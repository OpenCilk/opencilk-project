// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -S -emit-llvm -disable-llvm-passes -o - | FileCheck %s
// expected-no-diagnostics

template<class Char> class base {
protected:
  base();
  virtual ~base() noexcept;
};

extern base<char> var;

template<typename Char>
class derived final : public base<Char>
{
public:
    void reduce(derived* other);

    static void reduce(void *left_v, void *right_v);
    static void identity(void *view);
    ~derived() noexcept;
    derived();
    derived(const base<Char>& os);
};


extern void use(derived<char>&, const char *);

template<typename Char>
  using reducer = derived<Char>
    _Hyperobject(&derived<char>::identity, &derived<char>::reduce);

// CHECK-LABEL: testfn
int testfn(int argc, char *argv[]) {
    // Should call derived::derived(const base &)
    // CHECK: ptr @_Znwm
    // CHECK: void @_ZN7derivedIcEC1ERK4baseIcE
    reducer<char> *r = new reducer<char>(var);
    // Should lookup view
    // CHECK: @llvm.hyper.lookup
    // CHECK: call void @_Z3useR7derivedIcEPKc
    use(*r, "Hello\n");
    // CHECK-LABEL: delete.notnull
    // The destructor should be called directly as derived::~derived.
    // CHECK: call void @_ZN7derivedIcED1Ev
    // CHECK: call void @_ZdlPv
    delete r;
    return 0;
}
