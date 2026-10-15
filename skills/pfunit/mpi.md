# pFUnit MPI tests

Reference for testing MPI-parallel Fortran with pFUnit. The main [`SKILL.md`](SKILL.md) covers the serial path and the build setup; this file expands the MPI-specific detail. Unless the code under test is MPI-parallel, prefer serial tests — most ICCS projects (e.g. FTorch) use only the serial path.

## Basics

- MPI tests `use pFUnit`, which re-exports everything from `FUnit` plus the MPI types. (Not `use pfunit_mod` — that is the v3-era name kept in pFUnit's own self-tests under `bin/tests/`; the module was renamed and fails to compile on pFUnit 4.x.)
- The test-case type extends `MpiTestCase`; parameters extend `MpiTestParameter`.
- MPI support is detected automatically at pFUnit configure time when an MPI Fortran compiler is found (disable with `-DSKIP_MPI=YES`). It produces the extra `libpfunit` library alongside the serial `libfunit`.
- Every MPI `@test` subroutine takes the test-case argument (`class(MyCase), intent(inout) :: this`) — there are no argument-less MPI tests.

## Requesting the process count

- A default for the whole case: `npes=[1,2]` on `@testCase` — every test in the module runs on those counts.
- Override per-test: `@test(npes=[1,2], ...)` (equivalently `@mpitest(npes=[1,3,5])`).
- `cases=[...]` selects predefined MPI cases built by a parameter constructor (see below).

Running the executable directly with fewer ranks than requested does not crash — pFUnit reports "Insufficient processes to run this test" as a failure for the affected cases. Run under the requested count: `mpiexec -np <n> ./test_mpi`, or let CTest's `MAX_PES` handle it (below).

## The communicator: pass it into the code under test

pFUnit runs each `@test(npes=[...])` on a **sub-communicator it creates** for that test, sized to the requested ranks — not on `MPI_COMM_WORLD`. So when the code under test calls MPI routines, it must use pFUnit's communicator, not the world:

- **Design library routines to take the communicator as an argument** rather than hard-wiring `MPI_COMM_WORLD`. This is the standard "testable, composable MPI" pattern: in production the caller passes `MPI_COMM_WORLD` (or a split); in test the test passes pFUnit's communicator. (Corollary: the routine must not call `MPI_Init` — the pFUnit driver initializes MPI itself.)
- If a routine uses `MPI_COMM_WORLD` where pFUnit expects its own sub-communicator, the collective tries to talk to ranks pFUnit isn't driving in that test — it hangs or errors.
- Inside a test, the context is `this%context` (an `MpiContext`) with accessors `processRank()`, `getNumProcesses()`, `isRootProcess()`, and `getMpiCommunicator()` — the last returns the communicator pFUnit sized for the test. Pass that into MPI-calling procedures.

Worked example:

- `examples/mpi-multiply-mod.f90` — code under test whose `multiply_global(a, b, comm)` takes `comm` and does an `MPI_Allreduce` over it.
- `examples/mpi-comm-test.pf` — a test that calls it with `this%context%getMpiCommunicator()` and asserts the reduced result equals `4 * npes`, which only holds if the Allreduce ran over exactly pFUnit's sub-communicator.

Communicator type: the example uses the legacy `use mpi` module (integer `comm`), matching pFUnit's default `MpiContext` build. With `PF_USE_MPI_F08` the handle is a derived `MPI_Comm` instead (`use mpi_f08`) — keep the code-under-test's comm type consistent with the pFUnit build.

## Parameterized MPI tests

Extend `MpiTestParameter` with your own parameters. `numProcessesRequested` is inherited as the *first* component, so a bare `@testParameter` gives a default structure constructor taking `npes` first — entries can be written directly:

```fortran
@testParameter
type, extends(MpiTestParameter) :: MpiParams
  real :: phi
contains
  procedure :: toString
end type MpiParams

@test(testParameters={[MpiParams(1, 0.1), MpiParams(2, 0.2)]})
subroutine testA(this) ...
! or a getter: params = [(MpiParams(n, 1.0), n=1,8)]
```

Use `constructor=newMpiParams` only when you want `numProcessesRequested` set inside a function — e.g. for `cases=[...]`, where the generated suite calls `MpiParams(caseIndex)`:

```fortran
@testParameter(constructor=newMpiParams)
type, extends(MpiTestParameter) :: MpiParams ...   ! same type

function newMpiParams(i) result(p)   ! or (npes, phi) when called explicitly
  type(MpiParams) :: p
  integer, intent(in) :: i
  ! set p%phi ... then:
  call p%setNumProcessesRequested(npes_for_i)
end function newMpiParams

@test(cases=[1,2])   ! maps each case index through newMpiParams
subroutine testC(this) ...
```

Main runnable example: `examples/mpi-test.pf`. See also pFUnit's `bin/tests/inputs/MpiParameterizedTestCaseC.pf` for a full reference.

## Building

With CMake, pass `MAX_PES <n>` to `add_pfunit_ctest` so CTest runs the test under `mpiexec`; the MPI path links `libpfunit` (which includes `libfunit`):

```cmake
add_pfunit_ctest(test_mpi
  TEST_SOURCES mpi-test.pf
  OTHER_SOURCES mpi-multiply-mod.f90   # if the code under test also calls MPI
  MAX_PES 2
)
```

With Make, set `USEMPI=YES` before `include PFUNIT.mk`; it switches the link from `-lfunit` to `-lpfunit`. `PFUNIT` must be the exact install prefix (a parent dir is not enough — unlike CMake's `find_package`).
