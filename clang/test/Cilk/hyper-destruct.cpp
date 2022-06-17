// RUN: %clang_cc1 %s -x c++ -fopencilk -verify -disable-llvm-passes -S -emit-llvm -o - | FileCheck %s
// expected-no-diagnostics
template <typename T> class Bag;

template <typename T>
class Pennant
{
public:
  Pennant();
  Pennant(T*);
  ~Pennant();
  
  friend class Bag<T>;
};

template <typename T>
class Bag
{
  unsigned int field1;
  Pennant<T>* *bag;

  Pennant<T>* filling;

  unsigned int field2;

public:
  Bag();
  Bag(Bag<T>*);
  
  ~Bag();

  static void identity(void *value);
  static void reduce(void *left, void *right);
};

template <typename T>
Bag<T>::~Bag()
{
}

template<typename T>
using Bag_red = Bag<T> _Hyperobject(Bag<T>::identity, Bag<T>::reduce);

void f()
{
  Bag_red<int> b1;
  // Ensure that the destructor is emitted.
  // CHECK: define linkonce_odr void @_ZN3BagIiED2Ev
}
