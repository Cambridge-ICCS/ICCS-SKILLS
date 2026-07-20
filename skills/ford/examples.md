---
name: ford-examples
description: Complete, runnable examples of FORD documentation comments.
---

# FORD Documentation Examples

Complete, runnable examples demonstrating common FORD documentation patterns.

## Complete Subroutine — Numerical Integration

Shows documented arguments, abstract interfaces, notes/warnings, and cross-references.

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

## Complete Module

Shows metadata placement, public/private visibility, and working precision parameters.

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

## Multi-line Documentation Block

Shows the `!*` / `!` marker pattern for lengthy inline documentation.

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
