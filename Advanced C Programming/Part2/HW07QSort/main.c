// ***
// *** You must modify this file
// ***

#include <stdio.h>  
#include <stdlib.h> 
#include <string.h> 
#include <stdbool.h>
#include "hw07.h"

#ifdef TEST_MAIN
int main(int argc, char * * argv)
{
  // argv[1]: name of input file
  // argv[2]: name of output file

 if (argc != 3) // if argc is not 3, return EXIT_FAILURE
    {
      fprintf(stderr,"need the name of input and output file\n");
      return EXIT_FAILURE;
    }

  // count the number of integers in the file
  int numElem = 0;
  numElem = countInt(argv[1]);

  if (numElem == -1) // fopen fails
    {
      return EXIT_FAILURE;
    }

  int * arr = malloc(sizeof(int) * numElem);
  if (arr == NULL)
  {
    fprintf(stderr,"malloc fail\n");
    
    return EXIT_FAILURE;
  } 
   // allocate memory for the integers in the file
  // 1. create a pointer variable
  // 2. allocate memory
  // 3. check whether allocation succeed
  //    if allocation fails, return EXIT_FAILURE

  int * intArr = arr; // not sure
  
  bool rtv = readInt(argv[1], intArr, numElem);

  if (rtv == false) // read fail
    {
      return EXIT_FAILURE;
    }
  
  // call qsort using the comparison function you write
  qsort(&arr[0],numElem,sizeof(int),compareInt); // size of int or arr

  // write the sorted array to a file whose name is argv[2]
  
  rtv = writeInt(argv[2], intArr, numElem);
  if (rtv == false) // read fail
    {
      // release memory
      return EXIT_FAILURE;
    }
   
   free(arr);
   // everything is ok, release memory, return EXIT_SUCCESS

  return EXIT_SUCCESS;
}
#endif

