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
  _Cilk_for(int x : c) // expected-warning {{'_Cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: define void @_Z7iterateN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca %"struct.X::C"*, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store %"struct.X::C"* %[[C]], %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(%"struct.X::C"* %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], i32* %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(%"struct.X::C"* %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], i32* %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call i32 @_ZN1X1C2ItmiERS1_(%"struct.X::C::It"* %[[END]], %"struct.X::C::It"* dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORCOND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[PFORINC:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(%"struct.X::C::It"* %[[BEGIN]], i32 %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], i32* %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call dereferenceable(4) i32* @_ZN1X1C2ItdeEv(%"struct.X::C::It"* %[[ITER]])
// CHECK-NEXT: %[[ELEMVAL:.+]] = load i32, i32* %[[ELEM]], align 4
// CHECK-NEXT: store i32 %[[ELEMVAL]], i32* %[[X]], align 4

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void iterate_ref(X::C c) {
  _Cilk_for(int &x : c) // expected-warning {{'_Cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: define void @_Z11iterate_refN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca %"struct.X::C"*, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store %"struct.X::C"* %[[C]], %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(%"struct.X::C"* %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], i32* %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(%"struct.X::C"* %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], i32* %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call i32 @_ZN1X1C2ItmiERS1_(%"struct.X::C::It"* %[[END]], %"struct.X::C::It"* dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORCOND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[PFORINC:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca i32*, align 8
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(%"struct.X::C::It"* %[[BEGIN]], i32 %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], i32* %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call dereferenceable(4) i32* @_ZN1X1C2ItdeEv(%"struct.X::C::It"* %[[ITER]])
// CHECK-NEXT: store i32* %[[ELEM]], i32** %[[X]], align 8

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void iterate_auto(X::C c) {
  _Cilk_for(auto x : c) // expected-warning {{'_Cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: define void @_Z12iterate_autoN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca %"struct.X::C"*, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store %"struct.X::C"* %[[C]], %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(%"struct.X::C"* %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], i32* %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(%"struct.X::C"* %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], i32* %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call i32 @_ZN1X1C2ItmiERS1_(%"struct.X::C::It"* %[[END]], %"struct.X::C::It"* dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORCOND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[PFORINC:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(%"struct.X::C::It"* %[[BEGIN]], i32 %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], i32* %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call dereferenceable(4) i32* @_ZN1X1C2ItdeEv(%"struct.X::C::It"* %[[ITER]])
// CHECK-NEXT: %[[ELEMVAL:.+]] = load i32, i32* %[[ELEM]], align 4
// CHECK-NEXT: store i32 %[[ELEMVAL]], i32* %[[X]], align 4

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]

void iterate_autoref(X::C c) {
  _Cilk_for(auto &x : c) // expected-warning {{'_Cilk_for' support for for-range loops is currently EXPERIMENTAL only!}}
      bar(x);
}

// CHECK-LABEL: define void @_Z15iterate_autorefN1X1CE(

// CHECK: %[[C:.+]] = alloca %"struct.X::C", align 1
// CHECK-NEXT: %syncreg = call token @llvm.syncregion.start()
// CHECK-NEXT: %[[RANGE:.+]] = alloca %"struct.X::C"*, align 8
// CHECK-NEXT: %[[BEGIN:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[END:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: %[[CILKLOOPINDEX:.+]] = alloca i32, align 4
// CHECK-NEXT: %[[CILKLOOPLIMIT:.+]] = alloca i32, align 4
// CHECK-NEXT: store %"struct.X::C"* %[[C]], %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[CONTAINER:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[BEGINCALL:.+]] = call i32 @_ZN1X1C5beginEv(%"struct.X::C"* %[[CONTAINER]])
// CHECK-NEXT: %[[BEGINCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[BEGIN]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[BEGINCALL]], i32* %[[BEGINCOERCE]], align 4
// CHECK-NEXT: %[[CONTAINERAGAIN:.+]] = load %"struct.X::C"*, %"struct.X::C"** %[[RANGE]], align 8
// CHECK-NEXT: %[[ENDCALL:.+]] = call i32 @_ZN1X1C3endEv(%"struct.X::C"* %[[CONTAINERAGAIN]])
// CHECK-NEXT: %[[ENDCOERCE:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[END]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ENDCALL]], i32* %[[ENDCOERCE]], align 4
// CHECK-NEXT: store i32 0, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONTAINERLENGTH:.+]] = call i32 @_ZN1X1C2ItmiERS1_(%"struct.X::C::It"* %[[END]], %"struct.X::C::It"* dereferenceable(4) %[[BEGIN]])
// CHECK-NEXT: store i32 %[[CONTAINERLENGTH]], i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: br label %[[PFORCOND:.+]]

// CHECK: [[PFORCOND]]:
// CHECK-NEXT: br label %[[PFORDETACH:.+]]

// CHECK: [[PFORDETACH]]:
// CHECK-NEXT: %[[INITITER:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: detach within %[[SYNCREG:.+]], label %[[DETACHED:.+]], label %[[PFORINC:.+]]

// CHECK: [[DETACHED]]:
// CHECK-NEXT: %__local_loopindex = alloca i32, align 4
// CHECK-NEXT: %[[X:.+]] = alloca i32*, align 8
// CHECK-NEXT: %[[ITER:.+]] = alloca %"struct.X::C::It", align 4
// CHECK-NEXT: store i32 %[[INITITER]], i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[LOOPINDEXCOPY:.+]] = load i32, i32* %__local_loopindex, align 4
// CHECK-NEXT: %[[ITERREF:.+]] = call i32 @_ZN1X1C2ItplEi(%"struct.X::C::It"* %[[BEGIN]], i32 %[[LOOPINDEXCOPY]])
// CHECK-NEXT: %[[ITER2:.+]] = getelementptr inbounds %"struct.X::C::It", %"struct.X::C::It"* %[[ITER]], i32 0, i32 0
// CHECK-NEXT: store i32 %[[ITERREF]], i32* %[[ITER2]], align 4
// CHECK-NEXT: %[[ELEM:.+]] = call dereferenceable(4) i32* @_ZN1X1C2ItdeEv(%"struct.X::C::It"* %[[ITER]])
// CHECK-NEXT: store i32* %[[ELEM]], i32** %[[X]], align 8

// CHECK: [[PFORINC]]:
// CHECK-NEXT: %[[INCBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[INC:.+]] = add nsw i32 %[[INCBEGIN]], 1
// CHECK-NEXT: store i32 %[[INC]], i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDBEGIN:.+]] = load i32, i32* %[[CILKLOOPINDEX]], align 4
// CHECK-NEXT: %[[CONDEND:.+]] = load i32, i32* %[[CILKLOOPLIMIT]], align 4
// CHECK-NEXT: %[[COND:.+]] = icmp ne i32 %[[CONDBEGIN]], %[[CONDEND]]
// CHECK-NEXT: br i1 %[[COND]], label %{{.+}}, label %[[PFORCONDCLEANUP:.+]], !llvm.loop ![[LOOPMD:.+]]

// CHECK: [[PFORCONDCLEANUP]]:
// CHECK-NEXT: sync within %[[SYNCREG]]