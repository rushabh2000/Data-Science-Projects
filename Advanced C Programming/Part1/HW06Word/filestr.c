// ***
// *** You MUST modify this file.
// ***

#include <stdio.h>
#include <stdbool.h>
#include <string.h>

#ifdef TEST_COUNTWORD
int countWord(char * filename, char * word, char * line, int size)
{
  FILE *fptr;
  fptr = fopen(filename,"r");
  
  if(fptr == NULL)
  {
    return -1;
  }
  
  int sum = 0;
  char * tmp;
  while((tmp  = fgets (line,size,fptr)) != NULL)
  {
   while ((tmp = strstr(tmp,word)) != NULL)
   {
     tmp += strlen(word);
     sum++;
   }  
  }   

  // open a file whose name is filename for reading
  // if fopen fails, return -1. 
  // if fopen succeeds, set sum to zero
  // use fgets to read the file
  // if word appears in a line, add one to sum
  //
  // It is possible that the same word appears multiple times in a line
  // If this word is split in two or more lines, do not count the word.
  //
  // It is also possible that a long line is split by fgets. If this happens,
  // do not count the word.
  //
  // return sum
  //
  // If a line is "aaaaa" and the word is "aa", how is the count defined?
  // In this assignment, the first two letters are consumed when the
  // the first match occurs. Thus, the next match starts at the third
  // character. For this case, the correct answer is 2, not 4.
  
  return sum;
}
#endif
