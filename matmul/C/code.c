#include <stdio.h>
#include <stdlib.h>
#include <omp.h>

#define DEFAULT_N 1024
#define BLOCK_SIZE 32

// function prototypes
void fillRandom(float*, int);
void fillZeroes(float*, int);
void print2Darray(float*, int);

// main function
int main(int argc, char **argv) {
    int N;
    if (argc > 1) {
        N = atoi(argv[1]);
        printf("Each array is %d by %d\n", N, N);
        if (argc > 2) printf("(ignoring other parameters)\n");
    } else {
        N = DEFAULT_N;
        printf("Each array is %d by %d\n", N, N);
    }

    // allocate and initialize
    float *A = (float*) malloc(sizeof(float) * N * N);
    float *B = (float*) malloc(sizeof(float) * N * N);
    float *C = (float*) malloc(sizeof(float) * N * N);

    // check allocation
    if (A == NULL || B == NULL || C == NULL) {
        printf("failure to allocate arrays\n");
        free(A); free(B); free(C);
        return -1;
    }
    printf("malloc complete\n");

    // fix seed of PRNG
    srand(101);
    fillRandom(A, N);
    fillRandom(B, N);
    fillZeroes(C, N);

    printf("init complete\n");

#ifdef VERBOSE
    print2Darray(A, N);
    print2Darray(B, N);
#endif

    // optimized matmul with blocking
    #pragma omp parallel for collapse(2)
    for (int ii = 0; ii < N; ii += BLOCK_SIZE) {
        for (int jj = 0; jj < N; jj += BLOCK_SIZE) {
            for (int kk = 0; kk < N; kk += BLOCK_SIZE) {
                for (int i = ii; i < ii + BLOCK_SIZE && i < N; ++i) {
                    for (int j = jj; j < jj + BLOCK_SIZE && j < N; ++j) {
                        float sum = 0.0f;
                        for (int k = kk; k < kk + BLOCK_SIZE && k < N; ++k) {
                            sum += A[i * N + k] * B[k * N + j];
                        }
                        C[i * N + j] += sum;
                    }
                }
            }
        }
    }

#ifdef VERBOSE
    printf("matrix C (final answer)\n");
    print2Darray(C, N);
#else
    printf("C(%d,%d)=%f\n", N / 2, N / 2, C[(N / 2) * N + N / 2]);
#endif

    // free allocated memory
    free(A);
    free(B);
    free(C);

    return 0;
} // main

void fillRandom(float *array, int nSize) {
    // function to fill array with random numbers
    for (int i = 0; i < nSize * nSize; i++) {
        array[i] = (float)rand() / (float)RAND_MAX;
    }
}

void fillZeroes(float *array, int nSize) {
    // function to fill array with zeroes
    for (int i = 0; i < nSize * nSize; i++) {
        array[i] = 0.0f;
    }
}

void print2Darray(float *array, int nSize) {
    // function to print 2D array
    for (int j = 0; j < nSize; j++) {
        for (int i = 0; i < nSize; i++) {
            printf("array[%d][%d]=%f\n", i, j, array[i + nSize * j]);
        }
    }
}
