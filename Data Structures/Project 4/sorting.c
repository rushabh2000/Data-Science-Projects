//
//  sorting.c
//  
//
//  Created by rushabh ranka on 4/9/20.
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include"sorting.h"

void swap(long* a, long* b)
{
    long t = *a;
    *a = *b;
    *b = t;
}

void insertionSort(long arr[], int n)
{
    long i, key, j;
    for (i = 1; i < n; i++) {
        key = arr[i];
        j = i - 1;
  

        while (j >= 0 && arr[j] > key) {
            arr[j + 1] = arr[j];
            j = j - 1;
        }
        arr[j + 1] = key;
    }
}
long median (long a, long b, long c)
{

if(a < b)
{
    if (b < c)
    {
    return  b;
    }
    else if ( a < c)
    {
    return c;
    }
    else
       return  a;
}

else if (c < b)
{
return  b;
}
else if (c < a)
{
return c;
}
else

return a;
}
long partition(long arr[],long lb, long ub)

{

   long pivot = arr[lb];
    long down = lb;
    long up = ub;
    
    while ( down < up)
    {
      
      while((arr[down] <= pivot) & ( down < up))
      {
          down++;
      }
      while(arr[up] > pivot)
      {
          up--;
      }
      if (down < up)
      {
          swap(&arr[down],&arr[up]);
      }
    }
    arr[lb] = arr[up];
    arr[up] = pivot;
    
    return up;
}

void quicksort_helper(long arr[], long lb, long ub)
{
   while( ub > lb)
   {
       long med = median(arr[lb], arr[(lb + ub) / 2], arr[ub]);
       
       if( med == arr[(lb + ub) / 2])
       {
           swap(&arr[lb],&arr[(lb + ub) / 2]);
       }
       if( med == arr[ub])
       {
           swap(&arr[lb],&arr[ub]);
       }
       
       long pivot_idx = partition(arr, lb, ub); // small size
       if(pivot_idx < ((lb + ub) / 2 ))
       {
           quicksort_helper(arr, lb, pivot_idx - 1);
           lb = pivot_idx + 1;
       }
       else
       {
            quicksort_helper(arr, pivot_idx + 1, ub);
            ub = pivot_idx - 1;
     
       }
   }
    
}

void Quick_Sort(long *Array, int Size)
{
    long low = 0;

    quicksort_helper(Array,low,Size - 1);
   if (Size <= 20)
    {
    insertionSort(Array, Size);
    }

}
void bmerge(long *arr,long *tmp, int lb, int mid,  int ub )
{
    
    memcpy(&tmp[lb], &arr[lb], sizeof(long) * (mid - lb +1));

    int j =ub;
    for(int k = mid +1 ; k<= ub;k++)
    {
        tmp[k] = arr[j];
        j--;
    }
    int i =lb;
     j = ub;
    
    for(int k = lb;k<= ub;k++)
    {
      if(tmp[j] < tmp[i])
      {
          arr[k] = tmp[j--];
      }
      else
      {
            arr[k] = tmp[i++];
      }
    }
    
}

void merge_helper (long arr[],long tmp[], int lb,int ub)
{
    if (lb < ub)
    {
    int middle =  (lb+ub ) / 2 ;

    
    merge_helper(arr,tmp, lb, middle);
    merge_helper(arr,tmp, middle + 1, ub);
    bmerge(arr,tmp, lb,middle, ub);
    }
}
  
void Merge_Sort(long *Array, int Size)
{
    long *tmp= malloc(sizeof(long) * Size);
    merge_helper(Array,tmp,0, Size -1);
    free(tmp);
}

