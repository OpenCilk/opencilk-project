# The OpenCilk project

Welcome to the OpenCilk project!

[***OpenCilk***][SchardlLe23] is a state-of-the-art open-source
implementation of the Cilk task-parallel programming platform. 
OpenCilk supports writing fast task-parallel programs using the Cilk
task-parallel language extensions to C/C++.  In addition, OpenCilk
provides a platform to develop compilers, runtime systems, and
program-analysis tools for task-parallel code.

This repository contains the source code for the OpenCilk compiler,
which is based on the [LLVM compiler infrastructure](https://llvm.org/)
and implements the latest official version of
[***Tapir***][SchardlMoLe17], a compiler intermediate representation
(IR) for task parallelism.  OpenCilk also contains a
[parallel runtime library](https://github.com/OpenCilk/cheetah),
that automatically schedules and load-balances the Cilk computation,
and a [suite of tools](https://github.com/OpenCilk/productivity-tools),
including a race detector and a scalability analyzer.

This README provides a brief overview of how to get and use OpenCilk.
For more information about OpenCilk, including installation guides,
user guides, tutorials, and references, please see the
[OpenCilk website](https://www.opencilk.org/).

## Getting OpenCilk

**Supported systems:** OpenCilk has been tested on a variety of
modern x86-64 and 64-bit ARM processors, on recent versions of macOS and
FreeBSD, and on a variety of modern Linux distributions.

Releases of OpenCilk are available from the
[OpenCilk releases page](https://github.com/OpenCilk/opencilk-project/releases)
on GitHub.  Precompiled builds of OpenCilk for some releases and target
systems can be found on the same page.  Instructions to install OpenCilk
from a precompiled binary can be found on the
[install page](https://www.opencilk.org/doc/users-guide/install/) on the
OpenCilk website.

The scripts in the
[OpenCilk infrastructure](https://github.com/OpenCilk/infrastructure)
repository make it easy to build a particular release of OpenCilk from
source.  For example, the following steps will download the
OpenCilk release tagged `<release_tag>` into the `opencilk`
subdirectory in the current working directory, and the build OpenCilk
into the `build` subdirectory of the current working directory:
```console
git clone https://github.com/OpenCilk/infrastructure
infrastructure/tools/get -t <release_tag> $(pwd)/opencilk
infrastrcture/tools/build $(pwd)/opencilk $(pwd)/build
```

For more instructions on building OpenCilk from source, see the
[Build OpenCilk from source](https://www.opencilk.org/doc/users-guide/build-opencilk-from-source/)
guide.

## Building and running Cilk programs

To use OpenCilk to build and run Cilk programs, include the header file
`cilk/cilk.h` in your program's source code, and then compile and link
your program as you would an ordinary C/C++ program using OpenCilk's
`clang` or `clang++` binary and the additional `-fopencilk` flag.

For example, on Linux, the following command will build an optimized Cilk
executable `fib` from `fib.c` using OpenCilk, assuming that OpenCilk is
installed at `/opt/opencilk-2`:
```console
/opt/opencilk-2/bin/clang fib.c -o fib -O3 -fopencilk
```
On macOS, you will need XCode or Command Line Tools installed, to provide
the necessary system headers and libraries, and to preface your compile
and link commands with `xcrun`:
```console
xcrun /opt/opencilk-2/bin/clang fib.c -o fib -O3 -fopencilk
```

To run your Cilk program, simply run the resulting executable.
For example:
```console
./fib 40
```
You can specify the number of Cilk workers to use by setting the
`CILK_NWORKERS` environment variable.  For example, the following
command will run `fib` using 4 Cilk worker threads:
```console
CILK_NWORKERS=4 ./fib 40
```

## A quick introduction to Cilk programming

Cilk extends C and C++ with a few keywords to expose logical parallelism
in a program.  These keywords create parallel subcomputations, or
***tasks***, that are allowed to be scheduled and run simultaneously.
OpenCilk's runtime system automatically schedules and load-balances the
parallel tasks onto parallel processor cores in a shared-memory multicore
using randomized work stealing.

### Spawning and synchronizing tasks

The two most primitive Cilk keywords are `cilk_spawn` and `cilk_scope`.
A `cilk_spawn` can be inserted before a function call to allow that call
to execute in parallel with its continuation.  A `cilk_scope` defines a
lexical scope in which all spawned subcomputations must complete before
program execution leaves the scope.  Cilk supports ***recursive***
spawning of tasks, in which a task may itself spawn subtasks.

For example, the following Cilk program shows how one can
parallelize the simple exponential-time algorithm to compute the nth
Fibonacci number using `cilk_spawn` and `cilk_scope`.
```c
#include <stdio.h>
#include <stdlib.h>
#include <cilk/cilk.h>

int fib(int n) {
  if (n < 2)
    return n;
  int x, y;
  cilk_scope {
    x = cilk_spawn fib(n-1);
    y = fib(n-2);
  }
  return x+y;
}

int main(int argc, char *argv[]) {
  int n = 10;
  if (argc > 1)
    n = atoi(argv[1]);
  int result = fib(n);
  printf("fib(%d) = %d\n", n, result);
  return 0;
}
```

### Parallel loops

The `cilk_for` keyword can be used to define a parallel loop, in which all
iterations of the loop are allowed to execute simultaneously.  In Cilk,
`cilk_for` loops are safe and efficient to nest, as the following example
shows:
```c
#include <cilk/cilk.h>

void square_matmul(double *C, const double *A, const double *B, size_t n) {
  cilk_for (size_t i = 0; i < n; ++i) {
    cilk_for (size_t j = 0; j < n; ++j) {
      C[i * n + j] = 0.0;
      for (size_t k = 0; k < n; ++k) {
        C[i * n + j] += A[i * n + k] * B[k * n + j];
      }
    }
  }
}
```

## Using OpenCilk's tools

OpenCilk provides two Cilk-specific tools to check and analyze Cilk programs.
The Cilksan race detector checks Cilk programs dynamically for determinacy
races.  The Cilkscale scalability analyzer measures a Cilk program's parallel
scalability.

In addition, OpenCilk integrates standard tools packaged with LLVM for
analyzing C/C++ programs, including Google's sanitizers.  You can use those
tools with Cilk programs in the same way that you use them for regular C/C++
programs.  For example, to check your Cilk program for memory errors using
AddressSanitizer, compile and link your Cilk program with
the additional `-fsanitize=address` and then run it normally.

### Checking for races using Cilksan

For a given Cilk program and input, Cilksan is guaranteed to either detect a
determinacy race, if one exists, or certify that the program is
determinacy-race free.  For each race that Cilksan detects, it will produce
a race report that includes the memory address being raced on and the call
stacks of the two instructions involved in the race.  Cilksan will avoid
reporting races where both racing instructions are atomic operations or
protected by a common lock.  

To use Cilksan, compile and link the Cilk program with the additional
flag `-fsanitize=cilk`, and then run it normally.  It is also recommended
that you compile the Cilk program with debug symbols, by adding the `-g` flag,
to improve the readability of any race reports.

As an example, here is a Cilksan race report from building and running the
`nqueens` program in the
[OpenCilk tutorial](https://github.com/OpenCilk/tutorial) with Cilksan:
```
Race detected on location 1112ffd41
*     Read 100ffeb84 nqueens nqueens.c:64:3
|        `-to variable a (declared at tutorial/nqueens.c:50)
+     Call 100fffb80 nqueens nqueens.c:70:31
+    Spawn 100ffec8c nqueens nqueens.c:70:31
|*   Write 100ffed14 nqueens nqueens.c:68:12
||       `-to variable a (declared at nqueens.c:33)
\| Common calling context
 +    Call 100fffb80 nqueens nqueens.c:70:31
 +   Spawn 100ffec8c nqueens nqueens.c:70:31
 +    Call 100fff428 main nqueens.c:103:9
   Allocation context
    Stack object a (declared at nqueens.c:33)
     Alloc 100ffeb60 in nqueens nqueens.c:63:16
      Call 100fffb80 nqueens nqueens.c:70:31
     Spawn 100ffec8c nqueens nqueens.c:70:31
      Call 100fff428 main nqueens.c:103:9
```

### Measuring parallel scalability using Cilkscale

To use Cilkscale, compile and link the Cilk program with the additional flag
`-fcilktool=cilkscale`, and then run the program normally.

Cilkscale measures the work, span, and parallelism of a Cilk program
execution.  Cilkscale also produces "burdened" span and parallelism
measurements, which estimate the performance impact of scheduling overhead.

By default,Cilkscale reports these measurements in CSV format.  Here is an
example of Cilkscale's output.
```
tag,work (seconds),span (seconds),parallelism,burdened_span (seconds),burdened_parallelism
,2.07768,0.195024,10.6535,0.195386,10.6337
```
You can redirect Cilkscale's output to a file by setting the
`CILKSCALE_OUT` environment variable to that filename.

By default, Cilkscale measures the whole program execution.  Cilkscale also
provides a library API, similar to `clock_gettime()`, to measure specific 
regions of the program.  To measure a particular region in a Cilk program:
1. Include the Cilkscale header file, `cilk/cilkscale.h`, in the source
program.
2. Insert calls to the `wsp_getworkspan()` probe function around the region
   of interest.  For instance:
   ```c
   wsp_t start = wsp_getworkspan();
   // Region to measure
   wsp_t end = wsp_getworkspan();
   ```
3. Compute the difference between these probes and output the result, using
   the `wsp_sub()` method (or using the `-` operator on the `wsp_t` type in C++)
   and the `wsp_dump()` method.  For example:
   ```c
   wsp_t elapsed = wsp_sub(end, start);
   wsp_dump(dump, "my region tag");
   ```

The `wsp_dump()` function will add a line to the CSV output for the measured
region, tagged with the tag string passed to `wsp_dump()`.  For example:
```
tag,work (seconds),span (seconds),parallelism,burdened_span (seconds),burdened_parallelism
my region tag,1.94387,0.0868964,22.37,0.0871339,22.309
,2.05014,0.19316,10.6137,0.193398,10.6006
```

Cilkscale can also be used to automatically benchmark a Cilk program on
a range of processor counts and plot those performance results.  For more
information on Cilkscale's automatic benchmarking facility, see the
[Cilkscale user guide](https://www.opencilk.org/doc/users-guide/cilkscale/).

## Advanced Cilk programming features

OpenCilk supports several advanced parallel-programming features, including
reducer hyperobjects and deterministic parallel random-number generation.

### Reducer hyperobjects

OpenCilk supports ***reducer hyperobjects*** (or ***reducers*** for short)
to coordinate parallel modifications to shared variables.

Reducers provide a flexible parallel reduction mechanism.  When a Cilk
program runs, the OpenCilk runtime system automatically creates new
***views*** of a reducer, each initialized to an ***identity*** value, and
applies parallel modifications to the reducer to these independent views.
As parallel subcomputations complete, the runtime system automatically
combines these views in parallel, using a binary ***reduction*** operator.

A Cilk reducer produces a deterministic result, regardless of how the
program is scheduled at runtime, as long as its identity and reduction
operator defines a monoid.  In particular, an *associative* reduction
is all that's needed to get a deterministic result; the reduction need not
be commutative.

With OpenCilk, you can define a variable to be a reducer by adding the
keyword `cilk_reducer(I,R)` to its type, where `I` identifies a function
that sets the identity value, and `R` defines the binary reduction.  For
example, the following code defines the `sum` variable to be a reducer
by adding `cilk_reducer(zero_i, plus_i)` to its type:
```c
#include <cilk/cilk.h>

void zero_i(void *v) { *(int *)v = 0; }
void plus_i(void *l, void *r) { *(int *)l += *(int *)r; }

int sum_array(int *array, size_t n) {
  int cilk_reducer(zero_i, plus_i) sum = 0;
  cilk_for (size_t i = 0; i < n; ++i)
    sum += array[i];
  return sum;
}  
```
In this case, the function `zero_i` sets the identity value to be the
integer `0`, and `plus_i` defines a binary reduction of adding two
integers.

### Deterministic parallel random-number generation

OpenCilk supports deterministic parallel (pseudo)random-number
generation.  A deterministic parallel random-number generator (DPRNG)
produces repeatable results across multiple executions of a Cilk
program on a given input, regardless of parallel scheduling.

OpenCilk provides optimized support for a fast DPRNG.  This fast DPRNG
implements the
[DotMix](https://dl.acm.org/doi/10.1145/2145816.2145841) algorithm, which
produces 2-independent pseudorandom numbers. This fast DPRNG provides
two functions:
- The `__cilkrts_dprand_set_seed()` function seeds the DPRNG using a given
64-bit integer seed.
- The `__cilkrts_get_dprand()` function, which returns a 64-bit
pseudorandom value on each call.

To use this fast DPRNG, include the `cilk/cilk_api.h` header file and
link the program `-lopencilk-pedigrees`.

For example, the following Cilk program uses this fast DPRNG to
implement a parallel Monte Carlo algorithm for estimating pi:
```cpp
#include <cstdlib>
#include <cstdint>
#include <limits>
#include <cilk/cilk.h>
#include <cilk/cilk_api.h>

template <typename T> void zero(void *v) {
  *static_cast<T *>(v) = static_cast<T>(0);
}
template <typename T> void plus(void *l, void *r) {
  *static_cast<T *>(l) += *static_cast<T *>(r);
}

double estimatePi(int64_t n) {
  int64_t cilk_reducer(zero<int64_t>, plus<int64_t>) inside = 0;

  cilk_for (int64_t i = 0; i < n; ++i) {
    const double maxValue = static_cast<double>(std::numeric_limits<uint64_t>::max());

    // Get two samples
    uint64_t xSample = __cilkrts_get_dprand();
    uint64_t ySample = __cilkrts_get_dprand();

    double x = static_cast<double>(xSample) / maxValue;
    double y = static_cast<double>(ySample) / maxValue;
    double m = (x * x) + (y * y);
    
    // Check if sample is inside of the circle
    if (m <= 1)
      ++inside;
  }

  return 4.0 * static_cast<double>(inside) / static_cast<double>(n);
}
```

OpenCilk also supports the
[pedigree runtime mechanism](https://dl.acm.org/doi/10.1145/2145816.2145841)
for user-defined DPRNGs, using the same `cilk/cilk_api.h` header and
`-lopencilk-pedigrees` library.  At any point in a Cilk program, the
`__cilkrts_get_pedigree()` function returns the current pedigree in
the form of a singly linked list of `__cilkrts_pedigree` nodes.

## OpenCilk system architecture

The OpenCilk system has three core components: a compiler, a
runtime-system library, and a suite of tools.

The OpenCilk compiler (this respository) is based on the
[LLVM compiler infrastructure](https://llvm.org/).
The OpenCilk compiler extends LLVM with Tapir, a compiler IR
for task parallelism that enables effective compiler analysis and
optimization of task-parallel programs.

The OpenCilk [runtime library](https://github.com/OpenCilk/cheetah)
is based on the Cheetah runtime system.  This runtime system schedules
and load-balances the Cilk computation using a provably efficient
randomized work-stealing scheduler.

The OpenCilk [tool suite](https://github.com/OpenCilk/productivity-tools)
includes two tools for analyzing Cilk programs.  The Cilksan race
detector checks Cilk programs for determinacy races.  The Cilkscale
scalability analyzer measures the parallel scalability of Cilk
programs.

Although all OpenCilk components are integrated with each other,
OpenCilk's system architecture aims to make it easy to modify and
extend individual components.  OpenCilk's tools use
compiler-inserted instrumentation hooks that instrument LLVM's IR
and Tapir instructions.  Furthermore, the OpenCilk compiler
implements a general Tapir-lowering infrastructure that makes use
of LLVM bitcode — a binary representation of LLVM IR — to make it
easy to compile Cilk programs to use different parallel runtime
systems.  For more information, see the
[OpenCilk paper][SchardlLe23].

## How to cite OpenCilk

For the OpenCilk system as a whole, cite the
[OpenCilk conference paper][SchardlLe23] at ACM PPoPP 2023:
> Tao B. Schardl and I-Ting Angelina Lee.  2023.  OpenCilk: A Modular
> and Extensible Software Infrastructure for Fast Task-Parallel Code.
> In Proceedings of the 28th ACM SIGPLAN Annual Symposium on Principles
> and Practice of Parallel Programming (PPoPP '23). 189–203.
> https://doi.org/10.1145/3572848.3577509

BibTeX:
```bibtex
@inproceedings{SchardlLe23,
author = {Schardl, Tao B. and Lee, I-Ting Angelina},
title = {OpenCilk: A Modular and Extensible Software Infrastructure for Fast Task-Parallel Code},
year = {2023},
isbn = {9798400700156},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3572848.3577509},
doi = {10.1145/3572848.3577509},
booktitle = {Proceedings of the 28th ACM SIGPLAN Annual Symposium on Principles and Practice of Parallel Programming},
pages = {189–-203},
numpages = {15},
keywords = {bitcode, parallel runtime system, cilk, productivity tools, compiler-inserted instrumentation, tapir, compiling, task parallelism, fork-join parallelism, OpenCilk, oneTBB, OpenMP, parallel computing},
location = {Montreal, QC, Canada},
series = {PPoPP '23}
}
```

For the Tapir compiler IR, cite either the
[Tapir conference paper][SchardlMoLe17] at ACM PPoPP 2017 conference
paper or the [Tapir journal paper][SchardlMoLe19] in ACM TOPC 2019.

Tapir conference paper, ACM PPoPP 2017:
> Tao B. Schardl, William S. Moses, and Charles E. Leiserson. 2017.
> Tapir: Embedding Fork-Join Parallelism into LLVM's Intermediate
> Representation. In Proceedings of the 22nd ACM SIGPLAN Symposium
> on Principles and Practice of Parallel Programming (PPoPP '17).
> 249–265. https://doi.org/10.1145/3018743.3018758

BibTeX:
```bibtex
@inproceedings{SchardlMoLe17,
author = {Schardl, Tao B. and Moses, William S. and Leiserson, Charles E.},
title = {Tapir: Embedding Fork-Join Parallelism into LLVM's Intermediate Representation},
year = {2017},
isbn = {9781450344937},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
url = {https://doi.org/10.1145/3018743.3018758},
doi = {10.1145/3018743.3018758},
booktitle = {Proceedings of the 22nd ACM SIGPLAN Symposium on Principles and Practice of Parallel Programming},
pages = {249–-265},
numpages = {17},
keywords = {control-flow graph, multicore, tapir, openmp, fork-join parallelism, cilk, optimization, serial semantics, llvm, par- allel computing, compiling},
location = {Austin, Texas, USA},
series = {PPoPP '17}
}
```

Journal article about Tapir, ACM TOPC 2019:
> Tao B. Schardl, William S. Moses, and Charles E. Leiserson. 2019.
> Tapir: Embedding Recursive Fork-join Parallelism into LLVM’s
> Intermediate Representation. ACM Transactions on Parallel Computing 6,
> 4, Article 19 (December 2019), 33 pages. https://doi.org/10.1145/3365655

BibTeX:
```bibtex
@article{SchardlMoLe19,
author = {Schardl, Tao B. and Moses, William S. and Leiserson, Charles E.},
title = {Tapir: Embedding Recursive Fork-Join Parallelism into LLVM’s Intermediate Representation},
year = {2019},
issue_date = {December 2019},
publisher = {Association for Computing Machinery},
address = {New York, NY, USA},
volume = {6},
number = {4},
issn = {2329-4949},
url = {https://doi.org/10.1145/3365655},
doi = {10.1145/3365655},
journal = {ACM Transactions on Parallel Computing},
month = {dec},
articleno = {19},
numpages = {33},
keywords = {compiling, fork-join parallelism, Tapir, control-flow graph, optimization, parallel computing, OpenMP, multicore, Cilk, serial-projection property, LLVM}
}
```

## How to reach us

Found a bug in OpenCilk?  Please report it on the
[GitHub issue tracker](https://github.com/OpenCilk/opencilk-project/issues).

Have a question or comment?  Start a thread on the
[Discussions page](https://github.com/orgs/OpenCilk/discussions) or send us 
an email at [contact@opencilk.org](mailto:contact@opencilk.org).

Want to contribute to the OpenCilk project?  We welcome your
contributions!  Check out the
[contribute page](https://www.opencilk.org/contribute/) on the OpenCilk
website for more information.

## Acknowledgments

OpenCilk is supported in part by the National Science Foundation,
under grant number CCRI-1925609, and in part by the [USAF-MIT AI
Accelerator](https://aia.mit.edu/), which is sponsored by United
States Air Force Research Laboratory under Cooperative Agreement
Number FA8750-19-2-1000.

Any opinions, findings, and conclusions or recommendations expressed
in this material are those of the author(s) and should not be
interpreted as representing the official policies or views, either
expressed or implied, of the United states Air Force, the
U.S. Government, or the National Science Foundation.  The
U.S. Government is authorized to reproduce and distribute reprints for
Government purposes notwithstanding any copyright notation herein.

[SchardlLe23]: https://dl.acm.org/doi/10.1145/3572848.3577509
[SchardlMoLe17]: https://dl.acm.org/doi/10.1145/3155284.3018758
[SchardlMoLe19]: https://dl.acm.org/doi/10.1145/3365655
