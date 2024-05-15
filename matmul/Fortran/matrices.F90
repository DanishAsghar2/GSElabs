Module Matrices
  ! module defining required allocatable matrices, C=A*B
  real, dimension(:,:), allocatable:: A, B, C
  integer, dimension(:), allocatable:: seed
  integer, parameter:: DEFAULT_N = 1024
Contains
  Subroutine InitMatrices(N)
    ! fill A,B with random; fill C with zeroes

    Implicit None
    integer, intent(IN):: N
    integer:: numSeeds, ierr

    ! allocate and initialise
    allocate(A(N,N),STAT=ierr)
    if (ierr /= 0) stop "cannot allocate A"
    allocate(B(N,N),STAT=ierr)
    if (ierr /= 0) stop "cannot allocate B"
    allocate(C(N,N),STAT=ierr)
    if (ierr /= 0) stop "cannot allocate C"

    call random_seed(SIZE=numSeeds)
    write(*,*) 'expected #ints for seeds: ', numSeeds
    allocate(seed(numSeeds),STAT=ierr)
    if (ierr /= 0) stop "cannot allocate PRNG seed array"
    seed = 101
    call random_seed(PUT=seed(1:numSeeds))
    call fillRandom(A, N)
    call fillRandom(B, N)
    call fillZeroes(C, N)

    ! ! simple test. C(1,1)=14, C(1,2)=8, C(2,1)=4, C(2,2)=16
    ! A(1,1)=2.0
    ! A(2,1)=0.0
    ! A(1,2)=1.0
    ! A(2,2)=4.0
    ! B(1,1)=6.0
    ! B(2,1)=2.0
    ! B(1,2)=0.0
    ! B(2,2)=4.0

    
  End Subroutine InitMatrices

  Subroutine fillRandom(X, N)
    ! fill given 2D array with random numbers
    real, dimension(N,N):: X
    integer, intent(IN):: N
    integer i,j
    do i=1,N
       call random_number(X(i,:))
    end do
  End Subroutine FILLRANDOM

  Subroutine fillZeroes(X, N)
    ! fill given 2D array with zero
    real, dimension(N,N):: X
    integer, intent(IN):: N
    integer i,j
    do i=1,N
       do j=1,N
          X(i,j) = 0.0
       end do
    end do
  End Subroutine fillZeroes

  Subroutine printMatrix(X, N)
    ! output given 2D array 
    real, dimension(N,N):: X
    integer, intent(IN):: N
    integer i,j
    do i=1,N
       write(*,*) "ROW ",i
       do j=1,N
          write(*,*) X(i,j), ","
       end do
       write(*,*)
    end do
  end Subroutine printMatrix

End Module Matrices

