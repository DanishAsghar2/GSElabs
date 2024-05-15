/*
 * simple CUDA example to perform C=A*B matrix multiplication on GPU
 * 
 * For simplicity, value of C[i,j] is calculated by a thread from a 2D block. This may not be most efficient implementation!
 *
 * Each matrix is N*N
 *
 * mkbane (Dec2023)
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

#define DEFAULT_N 1024

// function prototypes
int fillRandom(float*, int);
int fillZeroes(float*, int);
void print2Darray(float*, int);

// CUDA kernel which runs on the GPU and is called from the host CPU
__global__ void myMM(float *C, float *A, float *B, int N) {
  /*
   * This kernel forms C=A*B where each matrix is N*N
  * NB various ways to do a 2D array in the C programming language.
  * This example flattens the array and then calcs relevant position 
  * in the array from the (row, col) indices
  *
  * The host CPU launches many instances of this kernel each running on a GPU thread
  * We are expecting 2D grid of blocks, with each block having 2D grid of threads
  * So, each thread has a unique thread index (threadIdx.x and threadIdx.y)
  * for each unique block index (blockIdx.x and blockIdx.y)
  * From thesse we can assign work to calc C[i,j]
  *
  */

  // rows are y-coords, cols are x-coords
  int myRow = (blockIdx.y * blockDim.y) + threadIdx.y;
  int myCol = (blockIdx.x * blockDim.x) + threadIdx.x;

  if (myRow<N && myCol<N) {
    // unlike serial version, we do NOT loop over rows, cols
    // (since we have one thread for each (row,col) combination)
    int pos_ij = myRow+N*myCol;
    //DEBUG: printf("thread: myRow,myCol = %d,%d calculating C[%d]\n", myRow, myCol, pos_ij);
    int pos_ik, pos_kj;
    for (int k=0; k<N; k++) {
      pos_ik = myRow+N*k;
      pos_kj = k+N*myCol;
      //DEBUG: printf("to calc C[%d] += A[%d] * B[%d]\n adding %f * %f to %f\n",pos_ij,pos_ik,pos_kj,A[pos_ik],B[pos_kj],C[pos_ij]);
      C[pos_ij] += A[pos_ik]*B[pos_kj];
    }
    //DEBUG: printf("thread: C[%d]=%f\n", pos_ij, C[pos_ij]);
  }
  else {
    //DEBUG: printf("this thread is skipping (myRow=%d, myCol=%d; c.f. N=%d\n", myRow, myCol, N);
  }
  // at this point C[i,j] for all valid (i,j) has been calculated
} // CUDA kernel myMM


// host CPU cost that launches multiply CUDA kernels
int main(int argc, char *argv[]) {
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

  // declare memory used on GPU
  // we use dev_VARNAME to indicate variable VARNAME on the device (i.e. GPU)
  float *dev_A, *dev_B, *dev_C;
  cudaMalloc(&dev_A, arrayMemSize);
  cudaMalloc(&dev_B, arrayMemSize);
  cudaMalloc(&dev_C, arrayMemSize);
  cudaError err = cudaGetLastError();
  if (err != cudaSuccess) printf("error [post cudaMalloc]\n%s\n", cudaGetErrorString(err));

  // copy values in each of A and B from host (CPU) too device (GPU)
  cudaMemcpy(dev_A, A, arrayMemSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dev_B, B, arrayMemSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dev_C, C, arrayMemSize, cudaMemcpyHostToDevice); // although would be best to zero on the GPU itself
  err = cudaGetLastError();
  if (err != cudaSuccess) printf("error [post memcpy to dev]\n%s\n", cudaGetErrorString(err));

  // 2D grid. symmetrical. For each extent we have N data points.
  // Let's set tpb (threads-per-block) for each extent to be 256.
  // We therefore need, for each extent, N/tpb blocks but need to ensure #blocks * #threads >= N
  int tpb = 32;
  int nBlocks = ceil( (float) N / (float) tpb);

  dim3 blocks2D(nBlocks, nBlocks, 1);
  dim3 tpb2D(tpb, tpb, 1);
  printf("For each extent:\n using %d blocks each of %d threads. Total #threads=%d c.f. N=%d\n", nBlocks, tpb, nBlocks*tpb, N);
  printf("Total threads on device will be %d\n", (nBlocks*nBlocks)*(tpb*tpb));
  myMM<<<blocks2D, tpb2D>>>(dev_C, dev_A, dev_B, N);
  cudaDeviceSynchronize();
  err = cudaGetLastError();
  if (err != cudaSuccess) {
    printf("error [post kernel] in CUDA kernel\n%s\n", cudaGetErrorString(err));
  }
  else {
    cudaDeviceSynchronize();
    // get result back onto host
    cudaMemcpy(C, dev_C, arrayMemSize, cudaMemcpyDeviceToHost); 
    #ifdef VERBOSE
    printf("matrix C (final answer)");
    print2Darray(C, N);
    #else
    // output given element of C
    //printf("C(%d,%d)=%f\n", N/2, N/2, C[N/2 + N * N/2]);
    printf("C(%d,%d)=%f\n", N/2, N/2, C[N/2,N/2]);
    #endif
  }

  // clean up and reset GPU
  free(A); free(B); free(C);
  cudaFree(dev_A); cudaFree(dev_B); cudaFree(dev_C);
  cudaDeviceReset();
  err = cudaGetLastError();
  if (err != cudaSuccess) printf("error [post cudaDeviceReset]\n%s\n", cudaGetErrorString(err));


  printf("Finito!\n");
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
