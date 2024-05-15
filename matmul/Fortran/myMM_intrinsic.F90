Program myMM
  ! Fortran code using F90 intrinsic "matmul" to form C=A*B for a given N
  USE Matrices
  Implicit None

!  INTERFACE
!     SUBROUTINE InitMatrices(N)
!     END SUBROUTINE InitMatrices
!  END INTERFACE

  integer:: N
  integer:: i,j,k
  character(len=8):: arg  ! string to represent "N"

  ! use command line arg if avail to determine size of matrices
  if (command_argument_count() >= 1) then
     call get_command_argument(1, arg)
     read(arg,*) N
     write(*,*) "Each array is ", N, " by ", N
     if (command_argument_count() > 1) write(*,*) "(ignoring other parameters)"
  else
     N = DEFAULT_N
     write(*,*) "Each array is ", N, " by ", N
  end if

  call InitMatrices(N)

#ifdef VERBOSE
  write(*,*) "matrix A"
  call printMatrix(A,N)
  write(*,*) "matrix B"
  call printMatrix(B,N)
  write(*,*) "matrix C (zeroes)"
  call printMatrix(C,N)
#endif
  
  ! matmul, using intrinsic
  C = matmul(A,B)

#ifdef VERBOSE
  write(*,*) "matrix C (final answer)"
  call printMatrix(C,N)
#else
  ! output a given element of C (to prevent compiler optimising away all operations)
  write(*,*) "C(",N/2,",",N/2,")=",C(N/2,N/2)
#endif


End Program myMM
