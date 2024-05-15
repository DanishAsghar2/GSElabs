
CC := gcc
CCFLAGS = -O0 -fno-openmp

all:	myMM_ij.exe  myMM_ji.exe 

clean:
	$(RM) *.o *.exe

myMM_ij.exe:	myMM_ij.c
	$(CC) $(CCFLAGS)  $^ -o $@

myMM_ji.exe:	myMM_ji.c
	$(CC) $(CCFLAGS)  $^ -o $@


#myMM.o:	myMM.F90
#	$(CC) $(CCFLAGS) -c $< -o $@

