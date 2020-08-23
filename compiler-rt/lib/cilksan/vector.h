/* -*- Mode: C++ -*- */

#ifndef _VECTOR_H
#define _VECTOR_H

#include <assert.h>
#include <cstdio>
#include <cstdlib>
#include <inttypes.h>

#include "debug_util.h"

// Vector data structure for storing and maintaining data
// associated with the call vector.
template <typename VECTOR_DATA_T>
class Vector_t {
private:
  // Default capacity for call vector.  Tunable to minimize
  // resizing.
  static const int64_t DEFAULT_CAPACITY = 8;

  // vector, implemented as an array of VECTOR_DATA_T's
  VECTOR_DATA_T *_vector;
  // current capacity of vector
  int64_t _capacity;
  // current head of vector
  int64_t _head;

  // General method to resize the call vector.
  // Called by _double_cap() and _halve_cap().
  //
  // @param new_capacity New capacity of the call vector.
  void _resize(int64_t new_capacity) {
    // Save a pointer to the call vector
    VECTOR_DATA_T *old_vector = _vector;
    // Allocate new call vector array
    _vector = new VECTOR_DATA_T[new_capacity];
    // Determine amount to copy over
    int64_t copy_end = _capacity > new_capacity ? new_capacity : _capacity;

    // Copy contents of old call vector
    for (int64_t i = 0; i < copy_end; ++i)
      _vector[i] = old_vector[i];

    _capacity = new_capacity;

    // Delete old call_vector
    delete[] old_vector;
  }

  // Doubles the capacity of the call vector.
  void _double_cap() { _resize(_capacity * 2); }

  // Halves the capacity of the call vector.
  void _halve_cap() { _resize(_capacity / 2); }


public:
  // Default constructor
  Vector_t() : _capacity(DEFAULT_CAPACITY), _head(-1) {
    _vector = new VECTOR_DATA_T[_capacity];
  }

  // Destructor
  ~Vector_t() { delete[] _vector; }

  // Return true if the vector is empty, false otherwise.
  bool isEmpty() const { return _head >= 0; }

  // Returns the current size of the vector, i.e., the number of entries on the
  // vector.
  int64_t size() const { return _head + 1; }

  // Clear the vector
  void clear() {
    _head = -1;
    delete[] _vector;
    _vector = new VECTOR_DATA_T[DEFAULT_CAPACITY];
    _capacity = DEFAULT_CAPACITY;
  }

  // Push val onto the back of the vector.
  void push_back(VECTOR_DATA_T val) {
    ++_head;

    if (_head == _capacity)
      _double_cap();

    _vector[_head] = val;
  }

  // Retrieves a VECTOR_DATA_T at index i, specifically a
  // pointer to that data on the call vector.
  //
  // @param i the index of the vector element,
  // where element at index 0 is the oldest element.
  VECTOR_DATA_T &at(int64_t i) const {
    cilksan_assert(i >= 0 && i <= _head);
    cilksan_assert(_head < _capacity);
    return _vector[i];
  }

  VECTOR_DATA_T &operator[](int64_t i) const {
    return at(i);
  }

  // Methods to enable use in range-for loops
  VECTOR_DATA_T *begin() const { return _vector; }
  VECTOR_DATA_T *end() const { return _vector + _head + 1; }
};

#endif // #define _VECTOR_H
