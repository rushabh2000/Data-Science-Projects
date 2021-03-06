//
//  eval.c
//  
//
//  Created by rushabh ranka on 4/25/20.
//

#include<stdio.h>
#include<string.h>
#include<stdlib.h>
#include"hbt.h"

void eval(char *filename)
{
    int validity =0;
    FILE *fptr  = fopen(filename,"rb");
     if(fptr == NULL){
      printf("-1 0 0\n");
     return false;
     }
    
    
}
