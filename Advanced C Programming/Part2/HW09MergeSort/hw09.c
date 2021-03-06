// ***
// *** You must modify this file
// ***
#include <stdio.h>  
#include <stdlib.h> 
#include <string.h> 
#include <stdbool.h>
#include "hw09.h"

// DO NOT MODIFY --->>>> From Here
// Do not modify this function. It is used for grading.
void printInput(char * msg, int * arr, int l, int m, int r)
{
  printf("%s(%6d, %6d, %6d)", msg, l, m, r);
  int ind;
  for (ind = l; ind <= r; ind ++)
    {
      printf("%d\n", arr[ind]);
    }
}
// DO NOT MODIFY <<<<--- Until Here

#ifdef TEST_READDATA
// the input file is binary, storing integers
//
// arr stores the address of a pointer for storing the
// address of the allocated memory
//
// size stores the address keeping the size of the array
bool readData(char * filename, int * * arr, int * size)
{
  
  FILE *fptr = fopen(filename,"rb");
  if( fptr == NULL)
  {
    return false;
  }
  
  int check = 0;
  check = fseek(fptr,0,SEEK_END);

  if(check == -1)
  {
   fclose(fptr);
   return false;
  }
  
  
  // use fopen to open the file for read
  // return false if fopen fails

  

  
  // use fseek to go to the end of the file
  // check whether fseek fails
  // if fseek fails, fclose and return false

  int size_tell = 0;
  size_tell = ftell(fptr);
  // use ftell to determine the size of the file


  int check2 = 0;

  check2 = fseek(fptr,0,SEEK_SET);
   if(check2 == -1)
  {
   fclose(fptr);
   return false;
  }


  // use fseek to go back to the beginning of the file
  // check whether fseek fails



  
  // if fseek fails, fclose and return false

  
  
  *size = size_tell / (sizeof(int)) ;
  // the number of integers is the file's size divided by
  // size of int  

  *arr =  malloc(sizeof(int) * *size);

  if(*arr == NULL)
  {
    fclose(fptr);
    return false;
  }
  // allocate memory for the array


  // if malloc fails, fclose and return false



  int correct = fread(*arr,sizeof(int),*size,fptr);
  // use fread to read the number of integers in the file

  if(correct != *size)
  {
     fclose(fptr);
     return false;
  }
  fclose(fptr);

  // if fread does not read the correct number
  // release allocated memory
  // fclose
  // return false




  
  // if fread succeeds
  // close the file

  
  // update the argument f or the array address


  
  // update the size of the  array


  
  return true;
}
#endif

#ifdef TEST_WRITEDATA
// the output file is binary, storing sorted integers
// write the array of integers to a file
// must use fwrite. must not use fprintf
bool writeData(char * filename, const int * arr, int size)
{
 
     FILE * fptr = fopen(filename, "w"); 
  if (fptr == NULL)
  { 
    return false;
  }
  // fopen for write
  // if fopen fails, return false

  int correct = fwrite(arr,sizeof(int),size,fptr);
 
  fclose(fptr); 
  return correct == size; 

  // use fwrite to write the entire array to a file



  // check whether all elements of the array have been written



  // fclose


  
  // if not all elements have been written, return false



  // if all elements have been written, return true





}
#endif


#ifdef TEST_MERGE
// input: arr is an array and its two parts arr[l..m] and arr[m+1..r]
// are already sorted
//
// output: arr is an array and all elements in arr[l..r] are sorted
//
// l, m, r mean left, middle, and right respectively
//
// You can assume that l <= m <= r.
//
// Do not worry about the elements in arr[0..l-1] or arr[r+1..]

static void merge(int * arr, int l, int m, int r)
// a static function can be called within this file only
// a static function is invisible to other files
{
  // at the beginning of the function
#ifdef DEBUG
  // Do not modify this part between #ifdef DEBUG and #endif
  // This part is used for grading. 
  printInput("Merge in", arr, l, m, r);
#endif
 if (r-l == 0) return;

 int *arr_1 = malloc(sizeof(int) * (m+1-l));
 int *arr_2 = malloc(sizeof(int) * (r-m));
  
  // if one or both of the arrays are empty, do nothing
  if( (arr_1 == NULL)) 
  {
    if (arr_2 != NULL) free(arr_2);
    return;
  }
  if ( (arr_2 == NULL) ) return;

  int n1 = m+1 -l;
  int n2 = r-m;
 
  for (int i = 0; i < n1; i++) 
  {
  arr_1[i] = arr[l+i];
  }
  for (int j = 0; j < n2; j++) 
  {
  arr_2[j] = arr[m+1+j];
  }

  int i = 0;
  int j = 0;
  int k = l;
  
  while(i < n1 && j <n2)
  {
    if (arr_1[i] <= arr_2[j])
    {
       arr[k] = arr_1[i];
       i++;    
    }
    else
    {
     arr[k] = arr_2[j];
     j++;
    }
    k++;
   }

  while ( i < n1)
  {
    arr[k] = arr_1[i];
    i++;
    k++;
   }

  while (j < n2)
  {
    arr[k] = arr_2[j];
    j++;
    k++;
  }

 free(arr_1);
 free(arr_2); 

  


  // Hint: you may consider to allocate memory here.
  // Allocating additiional memory makes this function easier to write




  // merge the two parts (each part is already sorted) of the array
  // into one sorted array

  



  


  // the following should be at the bottom of the function
#ifdef DEBUG
  // Do not modify this part between #ifdef DEBUG and #endif
  // This part is used for grading. 
  printInput("Merge out", arr, l, m, r);
#endif
}
#endif

// merge sort has the following steps:

// 1. if the input array has one or no element, it is already sorted
// 2. break the input array into two arrays. Their sizes are the same,
//    or differ by one
// 3. send each array to the mergeSort function until the input array
//    is small enough (one or no element)
// 4. sort the two arrays 
#ifdef TEST_MERGESSORT
void mergeSort(int arr[], int l, int r) 
{
  // at the beginning of the function
#ifdef DEBUG
  // Do not modify this part between #ifdef DEBUG and #endif
  // This part is used for grading. 
  printInput("mergeSort", arr, l, r, -1);
#endif

  // if the array has no or one element, do nothing
  if (r-l <= 0) return;
  
  if ( l < r)
  {
  int m = (l + r) /2;
  mergeSort(arr, l, m);
  mergeSort(arr,m+1,r);
  merge(arr,l,m,r);
  
  }
  // divide the array into two arrays
  // call mergeSort with each array
  // merge the two arrays into one
  




} 
#endif
