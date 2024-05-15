/*
 * C code to take (time fields, power field) from file ($1) and integrate to obtain energy
 * mkbane, Jan2024
 *
 * Correct version (requires no commas). Feb/Mar 2024
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>

#define TIMELEN 13
int timeLen = TIMELEN;

int main(int argc, char *argv[]) {
  double energy, width, x, y, meanHeight;  // for each trapezium
  double totalEnergy = 0.0;                 // overall (sum of all trapeziums)

  /*
   * required line format (after header) e.g. as from measure_GPU_dateTime_and_power.sh and preProcessed
   * timestamp power.draw 
   * where timestamp is YYYY/MM/DD hh:mm:ss.ddd
   *
   * ALGORITHM (trapezium rule, where _0 index is LHS and _1 index is RHS of given trapezium)
   * set totalEnergy as zero
   *
   * read first row as t_0, power_0 (ignoring other fields)
   * while (another row)
   *    read next row as t_1, power_1 (ignoring other fields)
   *    estimate energy for this trapezium & accumulate into totalEnergy
   *    set t_0 as t_1 and power_0 as power_1 ready for next step
   */

  if (argc != 2) {
    printf("%s requires name of file as sole parameter\n", argv[0]);
  }
  else {
    // open file, get initial row
    FILE* filePtr;
    filePtr = fopen(argv[1], "r"); // open file, given by sole parameter, as read-only
    if (filePtr == NULL) {
      printf("Cannot open file %s\n", argv[1]);
    }
    else {
      char buffer[40];  // for our case we usually have max of 31 chars per line
      char dateString[11], timeString[timeLen];
      char buf[timeLen-1];
      char startDateString[11];       // save dateString and throw error if changes
      double secsSinceMidnight_0, secsSinceMidnight_1;
      float power_0, power_1;

      // get initial data and parse 
      fgets(buffer, BUFSIZ-1, filePtr);
      printf("%s", buffer);
      int hour, minute;
      float sec;

      sscanf(buffer, "%s %d:%d:%f %f", &startDateString, &hour, &minute, &sec, &power_0);
      printf("date: %s\thour: %d\tminute: %d\tsecond: %f\t", startDateString, hour, minute, sec);
      secsSinceMidnight_0 = (double) hour*3600.0 + (double) minute*60.0 + (double) sec;
      printf("secs since midnight = %f\n", secsSinceMidnight_0);
      printf("power=%f W\n", power_0);
      
      // loop whilst more rows
      int numPairs = 0;
      double deltaTime, meanPower, partialEnergy;
      while (fgets(buffer, BUFSIZ-1, filePtr) != NULL) {
	numPairs++;
	printf("START: timeSecs=%f, power=%f W\n", secsSinceMidnight_0, power_0);
	printf("%s", buffer);
	sscanf(buffer, "%s %d:%d:%f %f", &startDateString, &hour, &minute, &sec, &power_1);
	printf("date: %s\thour: %d\tminute: %d\tsecond: %f\t", startDateString, hour, minute, sec);
	secsSinceMidnight_1 = (double) hour*3600.0 + (double) minute*60.0 + (double) sec;
	printf("secs since midnight = %f\n", secsSinceMidnight_1);
	printf("power=%f W\n", power_1);
	printf("FINISH: timeSecs=%f, power=%f W\n", secsSinceMidnight_1, power_1);
	deltaTime = (secsSinceMidnight_1 - secsSinceMidnight_0);
	meanPower = 0.5d * (double) (power_1 + power_0);
	partialEnergy = deltaTime * meanPower;
	printf("Delta time=%f, mean power=%f Watts ==> partial energy: %f Joules\n", \
	       deltaTime, meanPower, partialEnergy);
	totalEnergy += partialEnergy;
	printf("Total energy so far: %f Joules\n---\n", totalEnergy);
	// now set RHS to be LHS for any next step
	secsSinceMidnight_0 = secsSinceMidnight_1;
	power_0 = power_1;
      } // while
      printf("Read %d pairs of points.\nTotal energy = %f Joules\n", numPairs, totalEnergy);
    }
  }
}
