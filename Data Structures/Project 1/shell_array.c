#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include "shell_array.h"

//any helper functions must reside here.
//it is best that these helper functions be declared as static.

long *Array_Load_From_File(char *filename, int *size){
//determine the number of long integers in a file.
//*size is number of integers in the array.
//the function should return the address of the memory allocated for the long integers.
//if the input file is empty, an array of size 0 should still be created and *size be assigned 0.
//you should return a NULL address and assign 0 to *size if you could not open the file or fail to allocate sufficient memory
    FILE *fptr;
    fptr = fopen(filename,"rb");
    if(fptr == NULL) {
        *size = 0;
        return false;
    }
    long check = fseek(fptr,0,SEEK_END);
    if(check == -1) {
        fclose(fptr);
        return false;
    }
    long size_tell = ftell(fptr);
    long check2 = 0; 
    check2 = fseek(fptr,0,SEEK_SET);
    if(check2 == -1) {
        fclose(fptr);
        return false;
    }
    *size = size_tell / (sizeof(long));
    long *array = malloc(sizeof(long) * *size);
    if(array == NULL) {
        fclose(fptr);
        return false;
    }
    int correct = fread(array,sizeof(long),*size,fptr);
    if(correct != *size) {
        fclose(fptr);
        return false;
    }
    fclose(fptr);
    return array;    
}

int Array_Save_To_File(char *filename, long *array, int size) {
//the function saves array to an external file specified by filename in binary format.
//the output file and input file have same format.
//the integer returned should be the number of long integers in the array that have been successfully saved into the file.
//if array is NULL or size is 0, an empty output file should be created.
    FILE * fptr = fopen(filename, "wb"); 
    if (fptr == NULL) { 
        return false;
    }
    int correct = fwrite(array,sizeof(long),size,fptr);
    fclose(fptr); 
    // for (int i=0; i<size; i++) {
    //     printf("%d\n",array[i]);
    // }
    return correct;
}

bool less(long a, long b, long *n_comp) {
    *n_comp += 1;
    return a<b;
}

void Array_Shellsort(long *array, int size, long *n_comp) {
//the function takes in an array of long integers and sorts them using shellsort algorithm.
//size specifies the number of integers to be sorted.
//*n_comp should store the number of comparisons involving items in array throughout the entire process of sorting.
//use this sequence for sorting: 1,4,13,40,121,...
//a comparison that involves an item in array, e.g, temp < array[i] or array[i] < temp, corresponds to one comparison.
//a comparison that involves two items in array, e.g, array[i] < array[i-1], also corresponds to one comparison.
//comparisons such as i < j where i or j are indices are not considered as comparisons.
    int h = 1;
    while (h < size/3) h = 3*h + 1;
    while (h >= 1) {
        for (int i=h; i<size; i++) {
            for (int j=i; j>=h && less(array[j],array[j-h],n_comp); j-=h) {
                long temp = array[j-h];
                array[j-h] = array[j];
                array[j] = temp;
            }
        }
        h = h/3;
    }
}
