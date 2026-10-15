---
name: pfunit
description: Use this skill when writing, building, or parameterizing Fortran unit tests with the pFUnit framework, including .pf test files, assertions, fixtures, parameterized tests, and CMake or Make integration.
---

# What I do

I help write unit tests for Fortran code using [pFUnit](https://github.com/Goddard-Fortran-Ecosystem/pFUnit), the xUnit-style Fortran testing framework from the Goddard Fortran Ecosystem. This skill covers writing `.pf` test files, assertions, fixtures, parameterized tests, and building them with CMake (`add_pfunit_ctest`) or Make (`PFUNIT.mk`).

pFUnit's documentation is sparse; the patterns below follow ICCS projects such as FTorch.

# When to use this skill

Use this skill when the user asks to:

- Write or extend Fortran unit tests with pFUnit (`.pf` files, `@test`, `@assertEqual`)
- Set up pFUnit in a project (CMake or Make build integration)
- Parameterize Fortran tests (`@testParameter`, `ParameterizedTestCase`)
- Add fixtures (`setUp`/`tearDown`, `@before`/`@after`)
- Debug failing or non-compiling pFUnit tests
- Write tests in a codebase that already uses pFUnit (e.g. FTorch)

# Prerequisites

pFUnit must be built and installed once. It requires a Fortran compiler (gfortran assumed below) and CMake:

```bash
git clone https://github.com/Goddard-Fortran-Ecosystem/pFUnit.git
cd pFUnit
cmake -B build
cd build
make -j
make tests      # optional: verify the installation itself
make install
```

This installs under a prefix (e.g. `pFUnit/build/installed/PFUNIT-x.y/`):

```
PFUNIT-x.y/
├── bin/funitproc            # preprocessor that converts .pf -> .F90
├── cmake/PFUNITConfig.cmake # CMake package config (find_package entry point)
├── include/PFUNIT.mk        # Makefile include for non-CMake builds
├── include/*.mod            # compiled funit/fhamcrest module files
└── lib/                     # libfunit (serial), libpfunit (MPI)
```

CMake finds it given just the parent install dir (`.../installed`); Make needs the exact prefix (the directory holding `include/PFUNIT.mk`).

Optional MPI support is enabled automatically at CMake configure time when an MPI Fortran compiler is found (explicitly disable with `-DSKIP_MPI=YES`); this produces the additional `libpfunit` library.

# Core concepts

### .pf files are preprocessed Fortran

A pFUnit test file (conventionally `*.pf`) is Fortran source mixed with **preprocessor annotations** such as `@test` and `@assertEqual`. The `funitproc` tool converts each `.pf` file into a `.F90` file that is then compiled. You rarely run `funitproc` by hand — the CMake and Make integrations do it automatically.

### A test is a module

Each `.pf` file contains a Fortran **module** holding one or more tests:

```fortran
module unittest_multiply          ! module name should match the file basename
  use, intrinsic :: iso_fortran_env, only: wp => real64
  use funit                       ! brings in pFUnit types and assertion macros
  use multiply_mod, only: multiply_numbers  ! the code under test

  implicit none
  public

contains

  @test
  subroutine test_multiply_numbers()
    real(wp) :: product
    product = multiply_numbers(2.0_wp, 2.0_wp)
    @assertEqual(4.0_wp, product)
  end subroutine test_multiply_numbers

end module unittest_multiply
```

With the default CMake registry, the module name must equal the file basename (e.g. file `unittest_multiply.pf` → `module unittest_multiply`): the registry generates `ADD_TEST_SUITE(unittest_multiply_suite)` from the filename.

### Tests run via a generated driver

The build system generates a driver program (`<name>_driver.F90`) that assembles the test suites and runs them. With CMake, each `add_pfunit_ctest` call produces one executable registered with CTest — run it via `ctest` or directly.

### Serial vs MPI

- Serial tests `use funit` and link `libfunit`. Unparameterized `@test` subroutines take no arguments; parameterized ones take a test-case argument (see Parameterized tests below).
- MPI tests `use pFUnit`, define test cases by extending `MpiTestCase` (parameters via `MpiTestParameter`), require an MPI-enabled pFUnit build, and link `libpfunit` (which includes `libfunit`). Every MPI `@test` subroutine takes the `MpiTestCase` argument. See the MPI section below.

# Quick start: a simple test and build

Given a module `multiply_mod.f90` (see `examples/multiply_mod.f90`), write `unittest_multiply.pf` as in Core concepts above, then build with CMake:

```cmake
find_package(PFUNIT REQUIRED)
enable_testing()

add_library(multlib multiply_mod.f90)

add_pfunit_ctest(test_multiply
  TEST_SOURCES unittest_multiply.pf
  LINK_LIBRARIES multlib
)
```

Configure, build, and run:

```bash
cmake -B build -DCMAKE_PREFIX_PATH=<pfunit-install>
cmake --build build
cd build && ctest --verbose
# or run the test executable directly: ./build/test_multiply
```

Full working examples: `examples/simple-test.pf` and `examples/CMakeLists.txt.example`.

# Assertions

Assertions are preprocessor macros written inside test subroutines. Most take an optional trailing `message='...'` argument that is printed on failure.

| Macro | Purpose / signature notes |
|-------|---------------------------|
| `@assertEqual(expected, actual)` | Scalar or array equality (int, real, complex, logical, string). Optional `tolerance=` for real/complex. Optional `whitespace=IGNORE_DIFFERENCES` etc. for strings. |
| `@assertNotEqual(a, b)` | Inequality |
| `@assertTrue(cond)` / `@assertFalse(cond)` | Logical condition |
| `@assertLessThan(a, b)` / `@assertLessThanOrEqual(a, b)` | Ordering |
| `@assertGreaterThan(a, b)` / `@assertGreaterThanOrEqual(a, b)` | Ordering |
| `@assertRelativelyEqual(expected, actual, tolerance)` | Relative-tolerance comparison (reals) |
| `@assertIsFinite(x)` / `@assertIsInfinite(x)` / `@assertIsNaN(x)` | IEEE value checks |
| `@assertExceptionRaised(...)` | Assert that a pFUnit exception was thrown (used in framework self-tests) |

Examples:

```fortran
@assertEqual(4.0_wp, product)
@assertEqual(expected, product, tolerance=1.e-5_wp)
@assertEqual([1, 1], bracket)                        ! array comparison
@assertTrue(all(abs(computed - expected) < 1.0e-6), message='mismatch')
@assertEqual("Hello World!", greeting, whitespace=IGNORE_DIFFERENCES)
```

### Custom assertions (e.g. allclose with relative tolerance)

For arrays, `@assertEqual(expected, actual, tolerance=tol)` already does an elementwise comparison against a **scalar absolute** tolerance — that covers the common NumPy-`allclose(atol=...)` case. What pFUnit does *not* provide is a **relative**-tolerance (`rtol`) comparison across an array. A common pattern (used in FTorch) is a project utility module with a `logical` function performing the relative check, asserted on with `@assertTrue`:

```fortran
use my_test_utils, only: allclose
...
@assertTrue(allclose(computed, expected, rtol=1.0e-5, atol=1.0e-8), &
            message='tensor values differ')
```

### fHamcrest matchers

pFUnit ships an fHamcrest library with composable matchers via `call assert_that(actual, matcher)` (a **call**, not a `@` macro):

```fortran
call assert_that(2, is(equal_to(2)))
call assert_that(2, is(all_of([equal_to(2), not(equal_to(3))])))
call assert_that('abcd', ends_with('cd'))
call assert_that('abcd', contains_string('bc', ignoring_case=.true.))
call assert_that(x, is_near(1.0, 1.0e-6))
```

Available matchers include `is`, `equal_to`, `not`, `all_of`, `any_of`, `every`, `is_near`, `is_relatively_near`, `array_with_size`, `starts_with`, `ends_with`, `contains_string`. The `@assert*` macros are sufficient for most unit tests; reach for matchers when composing complex conditions.

# Parameterized tests

Parameterizing a test requires four pieces of infrastructure in the test module. The full runnable file is `examples/parameterized-test.pf`.

### 1. Define a testParameter type

Extend `AbstractTestParameter`, add your parameter variables, and bind a `toString` function (required by the abstract parent) that renders the parameter set for output. A `desc` string field is a convenient way to carry a human-readable label for each parameter set, returned by `toString` and reused as the assertion `message`:

```fortran
@testParameter
type, extends(AbstractTestParameter) :: MultiplyTestParameters
  real(wp) :: a, b, expected
  character(:), allocatable :: desc
contains
  procedure :: toString
end type MultiplyTestParameters
```

### 2. Define a testCase type with a constructor

Extend `ParameterizedTestCase`, holding your parameter type, and name its constructor in the annotation:

```fortran
@testCase(constructor=multiply_test_case_constructor)
type, extends(ParameterizedTestCase) :: MultiplyTestCase
  type(MultiplyTestParameters) :: params
end type MultiplyTestCase
```

The constructor takes parameters and stores them on the test case:

```fortran
function multiply_test_case_constructor(params)
  type(MultiplyTestCase) :: multiply_test_case_constructor
  type(MultiplyTestParameters), intent(in) :: params
  multiply_test_case_constructor%params = params
end function multiply_test_case_constructor
```

### 3. Write a parameter getter

A function returning an **allocatable array** of the parameter type — one entry per test instance:

```fortran
function get_multiply_parameters() result(params)
  type(MultiplyTestParameters), allocatable :: params(:)
  params = [ &
    MultiplyTestParameters( 2.0,  2.0,  4.0, "two positives"), &
    MultiplyTestParameters(-2.0,  2.0, -4.0, "negative * positive"), &
    MultiplyTestParameters( 3.3,  6.6, 21.78, "two non-integer reals") ]
end function get_multiply_parameters
```

Inline parameter lists are also allowed: `@test(testParameters={[MultiplyTestParameters(2.0, 2.0, 4.0, "case")]})`. To apply one parameter set to every `@test` in the module, put `testParameters` on the `@testCase` instead (`@testCase(testParameters={get_multiply_parameters()}, constructor=...)`) — each `@test` then runs once per parameter entry.

### 4. Annotate the test and take the test case as an argument

Attach the getter via `testParameters={...}` (note the braces), and give the subroutine an argument of the test case type:

```fortran
@test(testParameters={get_multiply_parameters()})
subroutine test_multiply_numbers(this)
  class(MultiplyTestCase), intent(inout) :: this

  real(wp) :: product
  product = multiply_numbers(this%params%a, this%params%b)
  @assertEqual(this%params%expected, product, tolerance=1.e-5, &
               message=trim(this%params%desc))
end subroutine test_multiply_numbers
```

The `toString` function is called by the driver to label each parameter instance in the output:

```fortran
function toString(this) result(string)
  class(MultiplyTestParameters), intent(in) :: this
  character(:), allocatable :: string
  string = trim(this%desc)
end function toString
```

# Fixtures (setUp / tearDown)

Two styles:

**Module-level `@before` / `@after`** — plain subroutines run before/after each test in the module. Good for file-based setup:

```fortran
@before
subroutine create_data()
  open(unit=10, file='testData.txt', form='formatted', status='replace')
  write(10,'(a)') 'record 1'
  rewind(10)
end subroutine create_data

@after
subroutine cleanup()
  close(10, status='delete')
end subroutine cleanup
```

**Type-bound `setUp` / `tearDown`** — for per-test-case state on an extended `TestCase` or `ParameterizedTestCase` type. No annotation needed; pFUnit calls them around every test:

```fortran
@testCase
type, extends(TestCase) :: InterpolatorTestCase
  type(LinearInterpolator) :: interpolator
contains
  procedure :: setUp
  procedure :: tearDown
end type InterpolatorTestCase
...
subroutine setUp(this)
  class(InterpolatorTestCase), intent(inout) :: this
  this%interpolator = LinearInterpolator([1.,2.,3.], [1.,1.,2.])
end subroutine setUp

subroutine tearDown(this)
  class(InterpolatorTestCase), intent(inout) :: this
end subroutine tearDown
```

Full example: `examples/fixtures-test.pf`.

# Building

## With CMake (recommended)

`find_package(PFUNIT)` provides `add_pfunit_ctest`:

```cmake
find_package(PFUNIT REQUIRED)
enable_testing()

add_library(mylib src/my_mod.f90)

add_pfunit_ctest(test_something
  TEST_SOURCES unittest_something.pf
  LINK_LIBRARIES mylib
)
```

Pass the install location at configure time:

```bash
cmake -B build -DCMAKE_PREFIX_PATH=<pfunit-install>
cmake --build build
cd build && ctest --output-on-failure
```

### add_pfunit_ctest arguments

| Argument | Purpose |
|----------|---------|
| `TEST_SOURCES` | `.pf` files to preprocess and compile (module name must match basename) |
| `LINK_LIBRARIES` | Libraries to link (your code under test as a library target) |
| `OTHER_SOURCES` | Extra sources (e.g. `.F90`, `.c`) compiled directly into the test without running through `funitproc` |
| `REGISTRY` | Custom `testSuites.inc` (rarely needed; a default is auto-generated) |
| `EXTRA_USE` | Extra module to `use` in the generated driver |
| `EXTRA_INITIALIZE` / `EXTRA_FINALIZE` | Procedures called before/after the whole run |
| `MAX_PES` | Run under `mpiexec` with this many processes (MPI builds) |
| `LABELS` | CTest labels for test selection (`ctest -L label`) |
| `WORKING_DIRECTORY` | Where the test executable runs |

Generated `.F90` files land in the current binary dir; test executables are standard CTest tests, so `ctest -R <name> -V`, `--output-on-failure`, etc. all work.

## With Make

For non-CMake projects, include `PFUNIT.mk` from the install and use the `make_pfunit_test` macro:

```make
include $(PFUNIT)/include/PFUNIT.mk   # PFUNIT = install prefix (exact; not a parent dir)
FFLAGS += $(PFUNIT_EXTRA_FFLAGS)

test_multiply_TESTS := unittest_multiply.pf
test_multiply_REGISTRY :=
test_multiply_OTHER_SOURCES :=
test_multiply_OTHER_LIBRARIES := -L. -lmultiply
test_multiply_OTHER_INCS :=

$(eval $(call make_pfunit_test,test_multiply))
```

Add `USEMPI=YES` for MPI builds. Full working file: `examples/Makefile.example`.

# MPI tests

pFUnit supports parallel tests via `MpiTestCase` / `MpiTestParameter` (build with an MPI-enabled pFUnit, i.e. `libpfunit`). MPI tests `use pFUnit`, extend `MpiTestCase`, request process counts with `npes=[...]` on `@testCase`/`@test`, and run under `mpiexec` (or CTest's `MAX_PES`). When testing MPI-parallel source, pass the communicator pFUnit creates for the test — `this%context%getMpiCommunicator()` — rather than letting the code use `MPI_COMM_WORLD`.

Unless the code under test is MPI-parallel, prefer serial tests — most ICCS projects (e.g. FTorch) use only the serial path. See [mpi.md](mpi.md) for the full MPI reference and examples (`examples/mpi-test.pf`, `examples/mpi-comm-test.pf`, `examples/mpi-multiply-mod.f90`).

# Gotchas

- **Implied save:** variables initialized at declaration inside a test get Fortran's implied `save` — mutated values persist across parameterized invocations. Always assign at the start of the test body, never at declaration:

  ```fortran
  integer, dimension(2) :: bad=[0, 1]   ! implied save — values persist!
  integer, dimension(2) :: good
  good = [0, 1]                          ! re-initialized every run
  ```

- **All-or-nothing parameterization per module:** if *any* test in a `.pf` module is parameterized, all `@test`s in that module must take the test-case argument. For tests needing no parameters, define a dummy single-entry getter:

  ```fortran
  function get_parameters_unparameterized() result(params)
    type(MyTestParameters), allocatable :: params(:)
    params = [MyTestParameters(0.0, "---")]
  end function get_parameters_unparameterized
  ```

- **Multiple parameter types in one module:** give each type its own `toString` implementation and bind with `procedure :: toString => toStringMultiply` / `=> toStringExponent` so output stays meaningful.

- **~132-char line limit → ~35-char test names:** the generated `suite%addTest(...)` line for parameterized tests is long; over-long test subroutine names cause compile-time line truncation. Keep test names ≤ ~35 characters and don't prefix everything with `test_` needlessly (the suite name already provides context).

- **Module name = file basename:** with the default registry, `foo_test.pf` must contain `module foo_test`. Mismatches produce "module not found"-style build errors in the driver.

- **`funitproc` needs `python` on the PATH:** the `.pf` preprocessor is a Python script with a `#!/usr/bin/env python` shebang. CMake finds an interpreter at configure time, but Make builds fail with `env: python: No such file or directory` on systems that only ship `python3` — run under a venv or symlink `python` to `python3`.

- **Braces vs brackets:** use `testParameters={getter_function()}` (braces) for a getter, `testParameters={[Param(...), Param(...)]}` (brackets) for an inline array. Mixing these up gives obscure preprocessor errors.

- **Preprocessor conditionals:** tests can be guarded with `@test(ifdef=SOME_MACRO)` and compiled conditionally with `target_compile_definitions(... PRIVATE SOME_MACRO)` — useful for GPU-only tests (FTorch uses separate CUDA `.pf` files instead).

- **`@suite(name='...')`** at module scope renames the reported suite; **`@disable`** before a test skips it.

# Workflow

1. **Check the install:** locate the pFUnit install prefix (the directory containing `cmake/PFUNITConfig.cmake`) — often under a vendored build. CMake accepts that prefix or its parent; Make needs the prefix itself.
2. **Identify the interface under test:** pick the public procedures of the module; keep the code in its own library target (`add_library`) so tests can link it.
3. **Write the `.pf` file:** start with a single `@test` and `@assertEqual`; name file and module identically.
4. **Set up build system:** `find_package(PFUNIT REQUIRED)` + `add_pfunit_ctest` (CMake) or `PFUNIT.mk` (Make).
5. **Build and run:** `cmake -B build -DCMAKE_PREFIX_PATH=... && cmake --build build && (cd build && ctest --output-on-failure)`.
6. **Parameterize** once basic tests pass: add the parameter type, test case, constructor, getter, and convert tests using the pattern above.
7. **Iterate:** read CTest output — failures print file, line, and the `toString` of the offending parameter set.

# Examples in this skill

| File | Contents |
|------|----------|
| `mpi.md` | Full MPI reference (`MpiTestCase`/`MpiTestParameter`, communicator pattern, MPI build) |
| `examples/multiply_mod.f90` | Tiny module under test used by the examples |
| `examples/simple-test.pf` | Minimal single-assertion test |
| `examples/parameterized-test.pf` | Complete parameterized test (types, constructor, getter, assertions) |
| `examples/fixtures-test.pf` | `@before`/`@after` and type-bound `setUp`/`tearDown` |
| `examples/mpi-test.pf` | MPI test case and parameters (`MpiTestCase`, `npes`) |
| `examples/mpi-multiply-mod.f90` | MPI code under test that takes a communicator argument |
| `examples/mpi-comm-test.pf` | Driving a comm-taking MPI routine from a test (`getMpiCommunicator()`) |
| `examples/CMakeLists.txt.example` | Full CMake build for the examples |
| `examples/Makefile.example` | Full Make build (PFUNIT.mk) for the examples |

# See also

- [pFUnit repository](https://github.com/Goddard-Fortran-Ecosystem/pFUnit) — source, self-tests (rich `.pf` examples under `tests/`), and `Examples/` directory
- [Parameterizing Fortran tests with pFUnit](https://jackatkinson.net/post/fortran_parameterizing_pfunit/) — walkthrough behind the parameterized pattern here
- [pfunit-parameterization-demo](https://github.com/jatkinson1000/pfunit-parameterization-demo) — minimal runnable demo (simple vs parameterized side by side)
- [FTorch test suite](https://github.com/Cambridge-ICCS/FTorch/tree/main/test/unit) — real-world ICCS usage, including custom `assert_allclose`-style utilities
