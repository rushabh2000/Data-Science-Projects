// ***
// *** You MUST modify this file.
// ***

#include <stdio.h>
#include <stdbool.h>

#ifdef TEST_ADDFILE
bool addFile(char * filename, int * sum)
{
 *sum = 0; // You cannot assume * sum is zero. Thus, * sum needs to be set 0
 FILE *fptr; // open a file whose name is filename for reading
 fptr = fopen(filename,"r");
   
  if(fptr == NULL) // if fopen fails, return false. Do NOT fclose
    {
      return false;
    }

  int oneint;
 
   while( fscanf(fptr,"%d",&oneint)!= EOF)
   {
    *sum = *sum + oneint;
   }
  fclose(fptr);
  // if fopen succeeds, read integers using fscan (do not use fgetc)
  //
  // * sum stores the result of adding all numbers from the file
  // When no more numbers can be read, fclose, return true
  //
  return true;
}
#endif


#ifdef TEST_WRITESUM
bool writeSum(char * filename, int sum)
{
 
 FILE *fptr; // open a file whose name is filename for writing
 fptr = fopen(filename,"w");  
 fprintf(fptr,"%d \n",sum);
 
fclose(fptr);
 // if fopen succeeds, write sum as an integer using fprintf
  // fprintf should use one newline '\n'
  // fclose, return true
  //
  return true;
}
#endif
