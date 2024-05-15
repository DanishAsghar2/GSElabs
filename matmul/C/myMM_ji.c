/*
 * matrix C = A*B, all of size N*N
 * mkbane (2023)
 * NB various ways to do a 2D array in the C programming language.
 * This example flattens the array and then calcs relevant position 
 * in the array from the (row, col) indices
 */
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define DEFAULT_N 1024

// function prototypes
int fillRandom(float*, int);
int fillZeroes(float*, int);
void print2Darray(float*, int);

// main function
int main(int argc, char **argv) {
  int N;
  if(argc>1) {
    N = atoi(argv[1]);
    printf("Each array is %d by %d\n", N,N);
    if(argc>2) printf("(ignoring other parameters)");
  }
  else {
    N = DEFAULT_N;
    printf("Each array is %d by %d\n", N,N);
  }

  // allocate and initialise
  float *A, *B, *C;
  int arrayMemSize=sizeof(float)*N*N;
  A = (float*) malloc(arrayMemSize);
  B = (float*) malloc(arrayMemSize);
  C = (float*) malloc(arrayMemSize);
  // check none of these failed
  if (A==NULL || B==NULL || C==NULL) {
    printf("failure to allocate arrays\n");
    abort();
  }
  printf("malloc complete\n");

  // fix seed of PRNG
  srand(101);
  int rc_A = fillRandom(A, N);
  int rc_B = fillRandom(B, N);
  int rc_C = fillZeroes(C, N);
  // check none of these failed
  if (rc_A != 0 || rc_B != 0 || rc_C !=0) {
    printf("failure to allocate arrays\n");
    abort();
  }

  printf("init complete\n");
#ifdef VERBOSE
  print2Darray(A, N);
  print2Darray(B, N);
#endif


  // naive matmul
  int pos_ij, pos_ik, pos_kj;
  for (int j=0; j<N; j++) {
    for (int i=0; i<N; i++) {
      for (int k=0; k<N; k++) {
	pos_ij = i+N*j;
	pos_ik = i+N*k;
	pos_kj = k+N*j;
	C[pos_ij] += A[pos_ik]*B[pos_kj];
      }
    }
  }

#ifdef VERBOSE
  printf("matrix C (final answer)");
  print2Darray(C, N);
#else
  // output given element of C
  printf("C(%d,%d)=%f\n", N/2, N/2, C[N/2, N/2]);
#endif


} // main

int fillRandom(float *array, int nSize) {
  // function to fill array with random numbers
  // note that rand returns integer so we divide by 1000 to get a float
  // and set zero as midpoint
  // where array is nSize * nSize
  // rc=0 upon success
  int rc = -1;
  for(int i=0; i<nSize*nSize; i++) {
    array[i] = (0.0001 * (float) rand()) - 0.00005*RAND_MAX;
  }
  rc = 0;
  return rc;
}

int fillZeroes(float *array, int nSize) {
  // function to fill array with zeroes
  // where array is nSize * nSize
  // rc=0 upon success
  int rc = -1;
  for(int i=0; i<nSize*nSize; i++) {
    array[i] = 0.00;
  }
  rc = 0;
  return rc;
}

void print2Darray(float *array, int nSize) {
  int row, col;
  // C stores data as col major
  for(int j=0; j<nSize; j++) {
    for(int i=0; i<nSize; i++) {
      printf("array[%d][%d]=%f\n",i,j,array[i+nSize*j]);
    }
  }
}
