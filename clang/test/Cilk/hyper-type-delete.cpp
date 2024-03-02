// Check that calling delete on a hyperobject produces a useful error message.
//
// RUN: %clang_cc1 %s -xc++ -fopencilk -verify -fsyntax-only
struct S {
    int x, y;
};
void identity(void *v);
void reduce(void *l, void *r);
using S_r = S _Hyperobject(identity, reduce);

class Foo {
    S_r r; // expected-warning{{reducer callbacks not implemented for structure members}}
public:
    ~Foo() { delete r; }; // expected-error{{cannot delete expression of type 'S_r' (aka 'S _Hyperobject(identity, reduce)')}}
};
