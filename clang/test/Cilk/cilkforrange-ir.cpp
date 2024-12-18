// RUN: %clang_cc1 %s -std=c++11 -triple x86_64-unknown-linux-gnu -fopencilk -ftapir=none -verify -S -emit-llvm -o - | FileCheck %s
//
// useful command:
//    ./clang++ -std=c++11 -fopencilk -ftapir=none -S -emit-llvm ../opencilk-project/clang/test/Cilk/cilkforrange-ir.cpp
//    cat cilkforrange-ir.ll | grep Z2upN1 -C 50

namespace X {
struct C {
  C();
  struct It {
    int value;
    int operator-(It &);
    It operator+(int);
    It operator++();
    It operator--();
    int &operator*();
    bool operator!=(It &);
  };
  It begin();
  It end();
};

} // namespace X

void bar(int i);

void iterate(X::C c) {
  _Cilk_for(int x : c) // expected-warning {{'cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: @_Z7iterateN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca ptr, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store ptr %[[C]], ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], ptr %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], ptr %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CALL:.+]] = call noundef i32 @_ZN1X1C2ItmiERS1_(ptr noundef nonnull align 4 dereferenceable(4) %[[END]], ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CALL]], ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORINITIALENTRY:.+]]

// CHECK: [[PFORINITIALENTRY]]:
// CHECK-NEXT: %[[FIRSTINDEX:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[LASTINDEX:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COMPARISON:.+]] = icmp ne i32 %[[FIRSTINDEX]], %[[LASTINDEX]]
// CHECK-NEXT: br i1 %[[COMPARISON]], label %[[PFORCOND:.+]], label %[[PFOREND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[PFORBODYENTRY:.+]], label %[[PFORINC:.+]]

// CHECK: [[PFORBODYENTRY]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]], i32 noundef %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], ptr %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN1X1C2ItdeEv(ptr noundef nonnull align 4 dereferenceable(4) %[[ITER]])
// CHECK-NEXT: %[[ELEMVAL:.+]] = load i32, ptr %[[ELEM]], align 4
// CHECK-NEXT: store i32 %[[ELEMVAL]], ptr %[[X]], align 4

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void iterate_ref(X::C c) {
  _Cilk_for(int &x : c) // expected-warning {{'cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: @_Z11iterate_refN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca ptr, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store ptr %[[C]], ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], ptr %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], ptr %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call noundef i32 @_ZN1X1C2ItmiERS1_(ptr noundef nonnull align 4 dereferenceable(4) %[[END]], ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORINITIALENTRY:.+]]

// CHECK: [[PFORINITIALENTRY]]:
// CHECK-NEXT: %[[FIRSTINDEX:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[LASTINDEX:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COMPARISON:.+]] = icmp ne i32 %[[FIRSTINDEX]], %[[LASTINDEX]]
// CHECK-NEXT: br i1 %[[COMPARISON]], label %[[PFORCOND:.+]], label %[[PFOREND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[PFORBODYENTRY:.+]], label %[[PFORINC:.+]]

// CHECK: [[PFORBODYENTRY]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca ptr, align 8
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]], i32 noundef %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], ptr %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN1X1C2ItdeEv(ptr noundef nonnull align 4 dereferenceable(4) %[[ITER]])
// CHECK-NEXT: store ptr %[[ELEM]], ptr %[[X]], align 8

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void iterate_auto(X::C c) {
  _Cilk_for(auto x : c) // expected-warning {{'cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: @_Z12iterate_autoN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca ptr, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store ptr %[[C]], ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], ptr %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], ptr %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call noundef i32 @_ZN1X1C2ItmiERS1_(ptr noundef nonnull align 4 dereferenceable(4) %[[END]], ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORINITIALENTRY:.+]]

// CHECK: [[PFORINITIALENTRY]]:
// CHECK-NEXT: %[[FIRSTINDEX:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[LASTINDEX:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COMPARISON:.+]] = icmp ne i32 %[[FIRSTINDEX]], %[[LASTINDEX]]
// CHECK-NEXT: br i1 %[[COMPARISON]], label %[[PFORCOND:.+]], label %[[PFOREND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[PFORBODYENTRY:.+]], label %[[PFORINC:.+]]

// CHECK: [[PFORBODYENTRY]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]], i32 noundef %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], ptr %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN1X1C2ItdeEv(ptr noundef nonnull align 4 dereferenceable(4) %[[ITER]])
// CHECK-NEXT: %[[ELEMVAL:.+]] = load i32, ptr %[[ELEM]], align 4
// CHECK-NEXT: store i32 %[[ELEMVAL]], ptr %[[X]], align 4

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void iterate_autoref(X::C c) {
  _Cilk_for(auto &x : c) // expected-warning {{'cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: @_Z15iterate_autorefN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca ptr, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store ptr %[[C]], ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], ptr %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load ptr, ptr %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(ptr noundef nonnull align 1 dereferenceable(1) %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], ptr %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call noundef i32 @_ZN1X1C2ItmiERS1_(ptr noundef nonnull align 4 dereferenceable(4) %[[END]], ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORINITIALENTRY:.+]]

// CHECK: [[PFORINITIALENTRY]]:
// CHECK-NEXT: %[[FIRSTINDEX:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[LASTINDEX:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COMPARISON:.+]] = icmp ne i32 %[[FIRSTINDEX]], %[[LASTINDEX]]
// CHECK-NEXT: br i1 %[[COMPARISON]], label %[[PFORCOND:.+]], label %[[PFOREND:.+]]


// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[PFORBODYENTRY:.+]], label %[[PFORINC:.+]]

// CHECK: [[PFORBODYENTRY]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca ptr, align 8
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, ptr %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(ptr noundef nonnull align 4 dereferenceable(4) %[[BEGIN]], i32 noundef %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", ptr %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], ptr %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call noundef nonnull align 4 dereferenceable(4) ptr @_ZN1X1C2ItdeEv(ptr noundef nonnull align 4 dereferenceable(4) %[[ITER]])
// CHECK-NEXT: store ptr %[[ELEM]], ptr %[[X]], align 8

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, ptr %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, ptr %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]