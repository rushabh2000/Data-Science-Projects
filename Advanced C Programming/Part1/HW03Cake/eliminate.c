// ***
// *** You MUST modify this file
// ***

#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h> 
#include <string.h> 

#ifdef TEST_ELIMINATE
// 100% of the score
void eliminate(int n, int k)
{
  // allocate an arry of n elements
  int * arr = malloc(sizeof(* arr) * n);
  // check whether memory allocation succeeds.
  // if allocation fails, stop
  if (arr == NULL)
    {
      fprintf(stderr, "malloc fail\n");
      return;
    }
 
  int count = 0;    // initialize all elements
  int flag = 0; 

  for (int i = 0; i < n; i++)
  {
  count = count + 1;
  
  if(arr[i] == -1)
  {
  count = count - 1;
  }
  
  if(count == k)
  { 
   printf("%d\n",i);
   count = 0;
   arr[i] = -1;
  }

  if( i == (n - 1 ))
  {
  i = 0 - 1 ;
  }

  for (int j = 0; j < n; j++)
  { 
    if( arr[j] == -1)
  {
    flag  = 1 + flag ;
  } 
  if ( flag == n)
{
  i = n;
}
}
  flag = 0; 
 }


  // counting to k,
  // mark the eliminated element
  // print the index of the marked element
  // repeat until only one element is unmarked




  // print the last one




  // release the memory of the array
  free (arr);
}
#endif
