// ***
// *** You MUST modify this file.
// ***

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#ifdef TEST_COUNTINT 
int countInt(char * filename)
{
  FILE * fptr = fopen(filename, "r"); // not sure if filename needs star
  if (fptr == NULL)
  {
    fprintf(stderr,"fopen fail\n");
    return -1;
  }
  int value;
  int count = 0;
  while(fscanf(fptr,"%d",&value) == 1) // should this consider the numbers corr
  {
    count++;
  }
 
  fclose(fptr);
  return count;
  // count the number of integers in the file
  // Please notice that if a file contains
  // 124 378 -56
  // There are three integers: 124, 378, -56
  // DO NOT count individual character '1', '2', '4' ...
  //
  // If fopen fails, return -1

  // remember to fclose if fopen succeeds
}
#endif

#ifdef TEST_READINT
bool readInt(char* filename, int * intArr, int size)
{
  FILE * fptr = fopen(filename, "r"); // not sure if filename needs star
  if (fptr == NULL)
  {
    fprintf(stderr,"fopen fail\n");
    return false;
  }
  
  int ind = 0;
  while (ind < size)
  {
  if (fscanf(fptr,"%d",& intArr[ind]) != 1)// is & before intArr needed
    {
      fprintf(stderr,"fscanf fail\n");
      return false;
    }
    ind ++; 
  }
  fclose(fptr);
  // if fopen fails, return false
  // read integers from the file.
  // 
  //
  // if the number of integers is different from size (too
  // few or too many) return false
  // 
  // if everything is fine, fclose and return true

  return true;
}
#endif

#ifdef TEST_COMPAREINT
int compareInt(const void *p1, const void *p2)
{
  const int * ptr1 = (const int *) p1;
  const int * ptr2 = (const int *) p2;
  int val1 = *ptr1;
  int val2 = *ptr2;
  if (val1 < val2) { return -1; }
  if (val1 == val2) { return 0; }
  return 1; 

  // needed by qsort
  //
  // return an integer less than, equal to, or greater than zero if
  // the first argument is considered to be respectively less than,
  // equal to, or greater than the second.
}
#endif

#ifdef TEST_WRITEINT
bool writeInt(char* filename, int * intArr, int size)
{
 FILE * fptr = fopen(filename, "w"); // not sure if filename needs star
  if (fptr == NULL)
  {
    fprintf(stderr,"fopen fail\n");
    return false;
  }

  for(int i = 0;i<size;i++)
  {
    fprintf(fptr, "%d\n",intArr[i]);  
  }

  fclose(fptr);
  return true;
  // if fopen fails, return false
  // write integers to the file.
  // one integer per line
  // 
  // fclose and return true
}
#endif
