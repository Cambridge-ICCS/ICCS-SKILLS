!| mpi_multiply_mod.f90
!  MPI variant of the code under test: takes the communicator to run on
!  rather than hard-wiring MPI_COMM_WORLD. This is the recommended pattern
!  for MPI-parallel library code: in production the caller passes
!  MPI_COMM_WORLD (or a split), under test the caller passes the
!  pFUnit-supplied communicator getMpiCommunicator().
!  Uses the legacy `mpi` module (integer communicator) to match pFUnit's
!  default MpiContext build; with PF_USE_MPI_F08 the comm is MPI_Comm instead.
!
!  Build alongside the MPI test with:
!    add_pfunit_ctest(test_mpi_comm
!      TEST_SOURCES mpi-comm-test.pf
!      OTHER_SOURCES mpi-multiply-mod.f90
!      MAX_PES 2)

module mpi_multiply_mod

  use, intrinsic :: iso_fortran_env, only: wp => real64
  use mpi

  implicit none

  public

contains

  !> Multiply a and b, then Allreduce the local product into a global one
  !  across the given communicator. Taking comm as an argument (not
  !  MPI_COMM_WORLD) lets a test drive this on whatever sub-communicator
  !  pFUnit assigned to the test; it also makes the routine composable in
  !  real codes that may already be running on a split communicator.
  function multiply_global(a, b, comm) result(product)
    real(wp), intent(in) :: a, b  !! local operands on this rank
    integer, intent(in) :: comm  !! communicator to reduce over
    real(wp) :: product  !! b*a summed over all ranks in comm

    real(wp) :: local
    integer :: ierr

    local = a * b
    call MPI_Allreduce(local, product, 1, MPI_DOUBLE_PRECISION, MPI_SUM, comm, ierr)

  end function multiply_global

end module mpi_multiply_mod
