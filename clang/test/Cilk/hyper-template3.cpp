// RUN: %clang_cc1 -x c++ %s --std=c++20 -fopencilk -verify -fsyntax-only
struct reducer_base {
  virtual ~reducer_base();
};

extern "C" reducer_base *__hyper_lookup_class(reducer_base *)
  __attribute__((nonnull, returns_nonnull));

template <typename T>
class Object {
protected:
    T x = 0;
public:
    // Object() = default;
    Object(T x) : x(x) {}
};

template <typename T>
class ObjectReducer : public reducer_base, public Object<T> {
public:
    // ObjectReducer() = default;
    ObjectReducer(Object<T> &o);
    ObjectReducer(const Object<T> &o);
    // operator Object<T>() const { return *this; }
    operator Object<T>&() const { return *this; }
};

template<typename T>
void do_stuff(Object<T> &o);

int main() {
    Object obj(4);
    ObjectReducer obj2(obj);
    ObjectReducer obj3 = Object(5);
    ObjectReducer<int> cilk_reducer objred(obj);
    ObjectReducer cilk_reducer objred2(obj);
    // expected-error@-1{{hyperobject of deduced}}
    // expected-error@-2{{view type must be a class}}
    // The second error is unwanted.
    ObjectReducer<int> cilk_reducer objred3 = Object(5);
    ObjectReducer cilk_reducer objred4 = Object(5);
    // expected-error@-1{{hyperobject of deduced}}
    // expected-error@-2{{view type must be a class}}
    // The second error is unwanted.
    do_stuff(*&objred);
    do_stuff(objred);
    return 0;
}
