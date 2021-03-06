// ***
// *** You must modify this file
// ***

#include <stdio.h>  
#include <stdlib.h> 
#include <string.h> 
#include <stdbool.h>
#include "hw08.h"

#ifdef TEST_MAIN
int main(int argc, char * * argv)
{

  // argv[1]: name of input file (binary)
  // argv[2]: name of output file (binary)

  if (argc != 3) // if argc is not 3, return EXIT_FAILURE
    {
      return EXIT_FAILURE;
    }

  int numElem = 0;
  numElem = countVector(argv[1]);

  if (numElem <= 0) // fopen fails
    {
      return EXIT_FAILURE;
    }

  Vector * arr = malloc(sizeof(Vector) * numElem);
  if (arr == NULL)
  {
    fprintf(stderr,"malloc fail\n");

    return EXIT_FAILURE;
  }

  int readcheck = 0;
  readcheck =  readVector(argv[1],arr,numElem);
  
    if( !readcheck ) 
  {
  return EXIT_FAILURE;
  }

  // check whether there are three arguments.
  // If not, return EXIT_FAILURE. DO NOT print anything

  // use argv[1] as the input to countVector, save the result

  // if the number of vector is 0 or negative, return EXIT_FAILURE

  // otherwise, allocate memory for an array of vectors

  // read the vectors from the file whose name is argv[1]. save the
  // results in the allocated array
  // if reading fails, release memory and return EXIT_FAILURE

#ifdef DEBUG
  printVector(arr, numElem);
#endif  

    
  qsort(&arr[0],numElem,sizeof(Vector),compareVector);
  
  // call qsort to sort the vectors, use argv[3] to determine which
  // attribute to sort

#ifdef DEBUG
  printf("\n");
  printVector(arr, numElem);
#endif  
  
  bool writecheck = writeVector(argv[2],arr,numElem);
  if( !writecheck )
 {
  free(arr);
  return EXIT_FAILURE;
  }
  // write the sorted array to the file whose name is argv[2]
  // if writing fails, release memory and return EXIT_FAILURE
  
  free(arr);
  return EXIT_SUCCESS; 
}               // releave memory, return EXIT_SUCCESS
#endif
