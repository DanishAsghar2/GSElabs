
# vanilla Python implementation without use of libraries
# to form matrix C = A*B 
# where matrix is implemented as numpy array

import numpy
import sys

def printArray(a, name):
    print("array: ", name)
    for col in range(0,n):
        for row in range(0,n):
            print("[", row, "][", col, "]=", a[row][col])


## matrix dimension
if(len(sys.argv)>1):
    print(sys.argv[1:])
    n = int(sys.argv[1])
    # quietly ignore any other args
else:
    n = 1024
print("matmul for array of dimension ", n)

## fill A, B with random numbers
numpy.random.seed(101)

## declare matrices as nested lists (using "list comprehension")
A = numpy.random.random((n,n))
B = numpy.random.random((n,n))

##VERBOSE: printArray(A,"A")
##VERBOSE: printArray(B,"B")

##  multiplication
C = numpy.matmul(A,B)

## output sample element
print("C[", n/2, "][", n/2, "]=", C[int(n/2)][int(n/2)])



