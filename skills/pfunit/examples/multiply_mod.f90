!| Module containing a multiply function
!  This is the "code under test" used by the pFUnit examples in this
!  directory. Replace it with your own module when writing real tests.

module multiply_mod
  use, intrinsic :: iso_fortran_env, only: wp => real64

  implicit none

  public

contains

  function multiply_numbers(a, b) result(product)
    real(wp), intent(in) :: a, b  !! Numbers to be multiplied
    real(wp) :: product  !! Result of the multiplication

    product = a * b
  end function multiply_numbers

end module multiply_mod
