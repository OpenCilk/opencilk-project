// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -fsyntax-only
// expected-no-diagnostics
template<typename Char>
class ostream_view {
  Char value;
public:
  void reduce(ostream_view* other);
  static void reduce(void *left_v, void *right_v);
  static void identity(void *view);
  static void destruct(void *view);
};

template<typename Char>
  using ostream_reducer = ostream_view<Char>
    _Hyperobject(&ostream_view<Char>::identity,
                 &ostream_view<Char>::reduce,
                 &ostream_view<Char>::destruct);

void f()
{
  // The types of a and b should be compatible.
  ostream_reducer<char> *a = nullptr; 
  ostream_reducer<char> *b = a; 
}
