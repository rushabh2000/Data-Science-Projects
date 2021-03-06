
//  Created by rushabh ranka on 4/9/20.
//  Copyright © 2020 rushabh ranka. All rights reserved.

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include"sorting.h"
long *Array_Load_From_File(char *filename, int*size)
{
  FILE *fptr;
  fptr = fopen(filename,"rb");

  if(fptr == NULL)
    {
      *size = 0;
      return false;
    }

  long check = fseek(fptr,0,SEEK_END);

  if(check == -1)
  {
    fclose(fptr);
    return false;
  }

  long size_tell = ftell(fptr);

  long check2 = 0;
   check2 = fseek(fptr,0,SEEK_SET);
   if(check2 == -1)
  {
   fclose(fptr);
   return false;
  }
  
  *size = size_tell / (sizeof(long));
  long *array = malloc(sizeof(long) * *size);
   // printf("aaja");
  if(array == NULL)
  {
    fclose(fptr);
    return false;
  }
  int correct = fread(array,sizeof(long),*size,fptr);

  if(correct != *size)
  {
     fclose(fptr);
     return false;
  }

  
fclose(fptr);
return array;
}
int Array_Save_To_File(char *filename,long *array,int size)
{
   
  FILE * fptr = fopen(filename, "wb");
  if (fptr == NULL)
  {
    return false;
  }

  int correct = fwrite(array,sizeof(long),size,fptr);
 
  fclose(fptr);
  return correct;
}
int main(int argc,char ** argv)
{
  if (argc != 4)
  {
    return EXIT_FAILURE;
  }
  char *type = argv[1];
  char *input = argv[2];
  char *output = argv[3];
  int size;
    
   
    
    bool sorting_option = strcmp(type,"-m");
    
    long *array = Array_Load_From_File(input,&size); // load to file
    if(array == NULL)
    {
     return EXIT_FAILURE;
    }
    if(sorting_option){
 
         // qsort(&array[0],size,sizeof(long),compareInt); // size of int or arr
          Quick_Sort(array,size); //call q  sort function here
        
        }
    else { // call merge sort function
        Merge_Sort(array,size);
    }
    
    long check;
     check = Array_Save_To_File(output,array,size);

     if(check != size)
       {
        return EXIT_FAILURE;
       }
    for(int i =0;i<size;i++)
    {
    printf("%ld\n",array[i]);
    }
    free(array); // save to file

     
    return EXIT_SUCCESS;

}


