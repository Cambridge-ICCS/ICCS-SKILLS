---
name: ford
description: Use this skill for adding FORD documentation comments to Fortran source code.
---

# What I do

I help write and embed FORD documentation comments directly into Fortran source files. FORD (FORtran Documenter) extracts documentation from specially marked comment lines in Fortran code to generate project documentation. This skill covers the comment syntax, metadata, formatting, and linking features that go into the source itself.

# When to use this skill

Use this skill when the user asks to:
- Add or update FORD documentation comments in Fortran `.f90`, `.f08`, or similar source files
- Document modules, subroutines, functions, derived types, variables, type-bound procedures, interfaces, programs, or submodules
- Write FORD metadata, summaries, notes/warnings, or cross-references in source code
- Convert existing plain `!` comments into FORD documentation comments

## FORD Documentation Basics

FORD uses `Markdown` within specially marked comment lines. The documentation comment markers are:

### Documentation Markers

| Marker | Name | Position | Description |
|--------|------|----------|-------------|
| `!!` | `docmark` | After the code | Standard documentation, placed **after** the construct on the same line or on the following lines |
| `!>` | `predocmark` | Before the code | Preceding documentation, placed **before** the construct (must be on the first line of the block) |
| `!*` | `docmark_alt` | After the code | Multi-line block: first line uses `!*`, subsequent lines use plain `!` |
| `\|` | `predocmark_alt` | Before the code | Multi-line block before code: first line uses `!|`, subsequent lines use plain `!` |

The `!!` marker is the most common. It goes after the construct being documented, either at the end of the declaration line or on a new line immediately below it.

### General Rules

- All documentation bodies are written in **Markdown** (including tables, code blocks, lists, etc.)
- LaTeX math is supported: inline with `\( ... \)`, display with `$$ ... $$` or `\[ ... \]`, numbered equations with `\begin{equation}...\end{equation}`
- Comments starting with a single `!` are regular code comments and are **ignored** by FORD

## Documenting Fortran Constructs

### Modules

Place documentation after `end module` on the following lines, or before the `module` keyword using `!>`:

```fortran
module my_module
  !! Provides utilities for mathematical operations.
  !!
  !! This module contains helper functions for vector and matrix
  !! computations.
  !!
  !! author: Jane Doe
  !! version: 1.0
  !! category: math

  implicit none
  private

  public :: vec_add, vec_dot

contains

  subroutine vec_add(a, b, c)
    ! ...
  end subroutine vec_add

end module my_module
```

Alternatively, preceding style:

```fortran
!> Provides utilities for mathematical operations.
!>
!> author: Jane Doe
module my_module
  implicit none
  private
end module my_module
```

### Subroutines and Functions

Document immediately after the `end subroutine`/`end function` line, or before the declaration with `!>`:

```fortran
subroutine vec_add(a, b, c)
  !! Adds two vectors element-wise.
  !!
  !! Computes `c = a + b` for two vectors of the same length.
  !!
  !! @note Both input vectors must have the same size.

  real, intent(in)  :: a(:)
      !! The first input vector.
  real, intent(in)  :: b(:)
      !! The second input vector.
  real, intent(out) :: c(:)
      !! The resulting vector.

  integer :: i

  do i = 1, size(a)
    c(i) = a(i) + b(i)
  end do

end subroutine vec_add
```

Preceding style with `!>`:

```fortran
!> Adds two vectors element-wise.
!>
!> Computes `c = a + b` for two vectors of the same size.
subroutine vec_add(a, b, c)
  real, intent(in)  :: a(:)
  real, intent(in)  :: b(:)
  real, intent(out) :: c(:)
  ! ...
end subroutine vec_add
```

### Derived Types

Document after the `end type` line or before the `type` declaration:

```fortran
type :: particle
  !! Represents a single particle in a simulation.
  !!
  !! Stores position, velocity, and mass for a particle.
  !!
  !! author: J. Smith
  !! version: 2.1

  real :: x, y, z       !! Position coordinates.
  real :: vx, vy, vz    !! Velocity components.
  real :: mass           !! Particle mass.

contains
  procedure, pass(self) :: kinetic_energy => particle_ke
      !! Computes the kinetic energy of this particle.
end type particle
```

### Variables

Document module-level and procedure-level variables inline at end of line, or on the following line:

```fortran
integer, parameter :: n = 100
    !! Number of grid points in the radial direction.

real, allocatable :: grid(:)
    !! The computational grid values.

logical :: converged = .false.
    !! Flag indicating whether the solver has converged.
```

Alternatively, preceding style on the variable's own line:

```fortran
integer, parameter :: n = 100  !! Number of grid points in the radial direction.
```

### Procedure Arguments (dummy arguments)

Document each argument on the line following its declaration:

```fortran
subroutine solve_system(A, b, x, tol, max_iter)
  !! Solves a linear system Ax = b using iterative methods.

  real, intent(in) :: A(:,:)
      !! The coefficient matrix.
  real, intent(in) :: b(:)
      !! The right-hand side vector.
  real, intent(out) :: x(:)
      !! The solution vector.
  real, intent(in), optional :: tol
      !! Convergence tolerance. Default: 1.0e-6.
  integer, intent(in), optional :: max_iter
      !! Maximum number of iterations. Default: 1000.

  ! ...
end subroutine solve_system
```

### Type-Bound Procedures

Document in the `contains` block of the type, on the line with or after the binding:

```fortran
type :: vector
  real, allocatable :: components(:)
contains
  procedure, pass(self), nopass => vec_norm
      !! Returns the Euclidean norm of this vector.
  procedure, pass(self) :: scale => vec_scale
      !! Scales this vector by a scalar factor.
end type vector
```

### Interfaces

```fortran
interface vec_add
  !! Generic interface for vector addition.
  module procedure vec_add_1d, vec_add_2d
end interface vec_add
```

### Programs

```fortran
program main
  !! Main entry point for the simulation runner.
  !!
  !! Reads configuration, initializes the simulation,
  !! and writes output results.

  ! ...
end program main
```

### Submodules

```fortran
submodule (parent_module) child_impl
  !! Implementation of abstract procedures declared in `parent_module`.

  ! ...
end submodule child_impl
```

## Documentation Metadata

Metadata must appear at the very top of a documentation block, before any other content or blank lines. Uses the format `key: value`.

### Recognized Metadata Keys

| Key | Example | Description |
|-----|---------|-------------|
| `author` | `author: Jane Doe` | Author of this code |
| `date` | `date: 2024-01-15` | Date written or documented |
| `version` | `version: 2.1` | Version identifier |
| `license` | `license: MIT` | License (use HTML for links) |
| `category` | `category: I/O` | Categorization label |
| `summary` | `summary: Fast matrix multiply` | Short description (overrides auto-extraction from first paragraph) |
| `deprecated` | `deprecated: true` | Marks the item as deprecated |
| `display` | `display: public` | Override visibility: `public`, `private`, `protected`, `none`, or combinations |
| `source` | `source: true` | Show/hide source code on documentation page |
| `graph` | `graph: false` | Exclude from call/caller graphs |
| `proc_internals` | `proc_internals: false` | Hide local variables/types inside a procedure |

### Correct Metadata Placement

```fortran
!> author: J. Smith
!> version: 1.0
!> summary: Computes the dot product of two vectors.
!>
!> Returns the scalar product of vectors x and y.
function dot_product(x, y) result(s)
```

This is **wrong** (metadata must come before any other documentation content):

```fortran
!>
!> author: J. Smith       !! WRONG - blank line before metadata
!> Computes the dot product.
function dot_product(x, y) result(s)
```

## Notes and Warning Boxes

Use boxed annotations to highlight important information:

| Tag | Purpose |
|-----|---------|
| `@note` | General note |
| `@warning` | Warning or caution |
| `@todo` | Outstanding task |
| `@bug` | Known bug |
| `@history` | Change history |

### Syntax

Multi-line block:
```fortran
!! @warning
!! Do not call this subroutine with an empty array.
!! @endwarning
```

Inline with paragraph:
```fortran
!! @note This function only works for symmetric matrices.
```

Custom title:
```fortran
!! @note "Performance Tip"
!! For large arrays, consider using the batched version.
!! @endnote
```

If a note appears in the first paragraph and no `@summary` metadata is set, the note content will be included in the auto-extracted summary. Place the note in a separate paragraph to avoid this.

## Cross-References (Links)

FORD provides a custom link syntax for referencing other documented entities: `[[component]]` or `[[component:member]]`.

### Link Syntax

```
[[name]]                        - Link by name only
[[name(type)]]                 - Link with type disambiguation
[[module:name]]                - Link to member within a module
[[module:type:member]]         - Fully qualified link
```

### Available Types

For the component (outer):
- `module`, `submodule`, `procedure`, `proc`, `subroutine`, `function`, `type`, `interface`, `absinterface`, `program`, `file`, `namelist`

For the member (inner):
- `variable`, `function`, `subroutine`, `bound`, `interface`, `type`, `constructor`, `final`, `modproc`, `common`, `absinterface`

Add `ext` prefix (e.g. `ext_module`) to reference items in external projects.

### Examples

```fortran
!! @see [[vec_add]] for the addition counterpart.
!! @see [[my_module:vec_dot]] for dot product computation.
!! @see [[matrix(type):inverse]] for the matrix inverse method.
```

In code examples within documentation, use backticks to prevent link resolution:
````
!! Usage: call [[my_module:solve_system]](A, b, x)
!! In code: `call solve_system(A, b, x)`  -- backticks prevent link resolution
````

## Doxygen-Style Documentation

FORD supports a limited subset of Doxygen commands as an alternative syntax:

| Doxygen | FORD equivalent |
|---------|-----------------|
| `@brief` | `@summary` |
| `@param name desc` | Documents a procedure argument |
| `@see name` | Cross-reference link |
| `@author` | `author` metadata |
| `@date` | `date` metadata |
| `@version` | `version` metadata |
| `@license` | `license` metadata |
| `@deprecated` | `deprecated` metadata |

```fortran
!> @brief Solves the linear system Ax = b.
!> @param A The coefficient matrix.
!> @param b The right-hand side vector.
!> @param x The computed solution.
!> @see [[vec_norm]] for computing residual norms.
subroutine solve(A, b, x)
```

Note: Doxygen commands must be on a single line. Multi-line Doxygen commands are not supported.

## Common Patterns and Best Practices

### Complete Subroutine Example

```fortran
subroutine integrate(f, a, b, n, result)
  !! Numerically integrates a function over an interval.
  !!
  !! Uses the composite trapezoidal rule with `n` sub-intervals
  !! to approximate the integral of `f` from `a` to `b`.
  !!
  !! @note The function `f` must be continuous on [a, b].
  !! @warning Results may be inaccurate for highly oscillatory functions.
  !!
  !! @see [[gauss_integrate]] for a higher-order alternative.

  abstract interface
    !! Function signature expected by the integrator.
    pure function func_interface(x) result(y)
      real, intent(in) :: x
      real :: y
    end function func_interface
  end interface

  procedure(func_interface), intent(in) :: f
      !! The function to integrate.
  real, intent(in) :: a
      !! Lower bound of the integration interval.
  real, intent(in) :: b
      !! Upper bound of the integration interval.
  integer, intent(in) :: n
      !! Number of sub-intervals for the trapezoidal rule.
  real, intent(out) :: result
      !! The approximated integral value.

  real :: h, sum_val
  integer :: i

  h = (b - a) / real(n)
  sum_val = 0.5 * (f(a) + f(b))

  do i = 1, n - 1
    sum_val = sum_val + f(a + real(i) * h)
  end do

  result = h * sum_val

end subroutine integrate
```

### Complete Module Example

```fortran
module math_utils
  !! Mathematical utility functions and types.
  !!
  !! This module provides common mathematical operations including
  !! vector arithmetic, matrix operations, and numerical integration.
  !!
  !! author: Development Team
  !! version: 3.0
  !! category: mathematics

  implicit none
  private

  public :: vec_add, vec_dot, mat_multiply, integrate, particle

  integer, parameter :: wp = kind(1.0d0)
      !! Working precision (double precision).

contains

  ! ... subroutine and function implementations ...

end module math_utils
```

### Multi-line Documentation Blocks

For lengthy documentation, use the `!*` marker (or `!*` followed by `!` lines):

```fortran
subroutine complex_algorithm(data, result)
  !* Complex algorithm with extensive documentation.
  !
  ! This subroutine implements a multi-step algorithm that
  ! processes the input data through several stages:
  !
  ! 1. Pre-processing and normalization
  ! 2. Main computational pass
  ! 3. Post-processing and result assembly
  !
  ! The algorithm has O(n log n) time complexity and requires
  ! O(n) additional memory.
  !
  ! @note Data must be pre-sorted by the 'id' field.
  ! @todo Add support for parallel execution.
  !
  ! @see [[simple_algorithm]] for a simpler but slower alternative.

  type(input_data), intent(in) :: data
  type(output_result), intent(out) :: result
  ! ...
end subroutine complex_algorithm
```

## Workflow

1. Identify the Fortran construct(s) the user wants to documented.
2. Determine whether to use following (`!!`) or preceding (`!>`) style. Use `!!` (following) by default for argument lists; either style is acceptable for procedure/type/module descriptions.
3. If metadata is relevant (author, version, summary, deprecated, etc.), place it as the **very first lines** of the doc block, before any other content.
4. Write a clear description in Markdown. Include:
   - What the construct does
   - Any constraints, invariants, or preconditions (use `@note` or `@warning`)
   - Known issues (`@bug`) or future work (`@todo`)
   - Cross-references to related code (`@see [[link]]`)
5. Document each dummy argument on the line after its declaration, describing purpose and any constraints.
6. For derived types, document each component variable and each type-bound procedure.
7. Keep documentation concise but complete. Prefer `!!` at end of line for short variable docs, and multi-line `!!` blocks for procedure/type/module descriptions.
8. If the user's codebase uses Doxygen-style comments consistently, use `@param`, `@brief`, `@see` etc. instead of the native FORD style for consistency.

## See Also

- [FORD Documentation](https://forddocs.readthedocs.io/) — Official FORD user guide and reference
- [FORD Repository](https://github.com/Fortran-FOSS-Programmers/ford) — Source code and issue tracker
- [fpm](https://fpm.fortran-lang.org/) — Fortran package manager (recommended for FORD-structured projects)
