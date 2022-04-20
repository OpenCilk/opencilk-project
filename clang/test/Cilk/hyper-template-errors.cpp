// RUN: %clang_cc1 %s -fopencilk -verify -fsyntax-only
template<typename VIEW>
struct reducer
{
  _Hyperobject VIEW value1; // expected-error{{type '_Hyperobject long', which contains a hyperobject, may not be a hyperobject}}
  _Hyperobject int value2;
};

reducer<_Hyperobject long> r_hl; // expected-note{{in instantiation}}
reducer<char> r_l;
reducer<int[2]> r_i2;

int f() { return r_l.value1 + r_l.value2; }
int g() { return r_i2.value1[0]; }
