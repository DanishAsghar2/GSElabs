
FC := gfortran
FCFLAGS = -O0 -fno-openmp

SRCS=$(wildcard *.F90)
OBJS=$(patsubst %.F90,%.o,$(SRCS))
MOD_SRC=matrices.F90
MOD_OBJ=matrices.o


all:	myMM_ij.exe myMM_ji.exe myMM_intrinsic.exe myMM_blas-implicit.exe myMM_blas.exe 

clean:
	$(RM) *.o *.mod *.exe

myMM_ij.exe:	matrices.o myMM_ij.F90
	$(FC) $(FCFLAGS)  $^ -o $@

myMM_ji.exe:	matrices.o myMM_ji.F90
	$(FC) $(FCFLAGS)  $^ -o $@

myMM_intrinsic.exe:	matrices.o myMM_intrinsic.F90
	$(FC) $(FCFLAGS)  $^ -o $@

myMM_blas-implicit.exe:	matrices.o myMM_intrinsic.F90
	$(FC) $(FCFLAGS) -fexternal-blas  $^ -llapack -lblas -o $@

myMM_blas.exe:	matrices.o myMM_blas.F90
	$(FC) $(FCFLAGS)  $^ -llapack -lblas -o $@


# # general patterns
# $(OBJS): %.o : %.F90
# 	$(FC) $(FCFLAGS) -c $< -o $@

myMM.o:	matrices.o myMM.F90
	$(FC) $(FCFLAGS) -c $< -o $@

myMM_intrinsic.o:	matrices.o myMM_intrinsic.F90
	$(FC) $(FCFLAGS) -c $< -o $@

myMM_blas-implicit.o:	matrices.o myMM_intrinsic.F90
	$(FC) $(FCFLAGS) -c $< -o $@

matrices.o:	matrices.F90
	$(FC) $(FCFLAGS) -c $<

# debugging - output internal variables
debug:
	@echo "SRCS=$(SRCS)"
	@echo "OBJS=$(OBJS)"


