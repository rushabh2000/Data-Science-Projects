//
//  main.c
//  pa1_xcode
//
//  Created by rushabh ranka on 5/1/20.
//  Copyright © 2020 rushabh ranka. All rights reserved.
//
#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "shell_list.h"
#include "shell_array.h"

int main(int argc,char * *argv) {
    // insert code here...

    
 
        if (argc != 4)
        {
            return EXIT_FAILURE;
        }
        char *type = argv[1];
        char * input = argv[2];
        char * output = argv[3];
        clock_t /*IOStart, IOStop,*/ SortStart, SortStop;
        long no_of_comp = 0;
        if (type[1] == 'a') {
            int size = 0;
            long *array = Array_Load_From_File(input,&size);
            SortStart = clock();
            Array_Shellsort(array,size,&no_of_comp);
            SortStop = clock();
            int int_copied = 0;
            int_copied = Array_Save_To_File(output,array,size);
            printf("%d number of integers successfully written to the file %s\n",int_copied,output);
        }
        else {
            int NodesCopied = 0;
            // IOStart = clock();
            Node *head = List_Load_From_File(input);
            SortStart = clock();
            Node* sorted_list = List_Shellsort(head, &no_of_comp);
            SortStop = clock();
            NodesCopied = List_Save_To_File(output,sorted_list);
            printf("%d number of integers successfully written to the file %s\n",NodesCopied,output);
            // IOStop = clock();
            // printf("I/O Time: %le\n", (float)((IOStop-IOStop)-(SortStop - SortStop))/CLOCKS_PER_SEC);
        }
        printf("No. of comparisons = %ld\n",no_of_comp);
        printf("Sorting Time: %lf seconds\n", (float)(SortStop - SortStart)/CLOCKS_PER_SEC);
        return EXIT_SUCCESS;
    }



