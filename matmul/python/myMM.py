
# vanilla Python implementation without use of libraries
# to form matrix C = A*B 
# where a vector implemented as Python list
# and a matrix is implemented as list of lists

import random
import sys

## matrix dimension
if(len(sys.argv)>1):
    print(sys.argv[1:])
    n = int(sys.argv[1])
    # quietly ignore any other args
else:
    n = 1024
print("matmul for array of dimension ", n)

## fill A, B with random numbers
random.seed(101)

## declare matrices as nested lists (using "list comprehension")
A=[[row * n + col for col in range(n)] for row in range(n)]
for col in range(0,n):
    for row in range(0,n):
        A[row][col] = random.random()
        ##VERBOSE: print("A[", row, "][", col, "]=", A[row][col])
               
B=[[row * n + col for col in range(n)] for row in range(n)]
for col in range(0,n):
    for row in range(0,n):
        B[row][col] = random.random()
        ##VERBOSE: print("B[", row, "][", col, "]=", B[row][col])

## naive multiplication
C=[[row * n + col for col in range(n)] for row in range(n)]
for i in range(0,n):
    for j in range(0,n):
        C[i][j] = 0.0
        for k in range(0,n):
            C[i][j] += A[i][k] * B[k][j]

##VERBOSE: # output result
##VERBOSE: for col in range(0,n):
##VERBOSE:     for row in range(0,n):
##VERBOSE:         print("C[", row, "][", col, "]=", C[row][col])

## output sample element
print("C[", n/2, "][", n/2, "]=", C[int(n/2)][int(n/2)])



