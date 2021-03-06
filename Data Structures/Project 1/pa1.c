#include <stdio.h>
#include <stdbool.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include "shell_list.h"
#include "shell_array.h"
static void free_node(Node*list){
Node *next_ptr = list;
while(next_ptr != NULL)
{
  list = next_ptr;
  next_ptr = list->next;
  free(list);
} }

int main(int argc, char **argv) {
    if (argc != 4)
        return EXIT_FAILURE;
    char *type = argv[1];
    char *input = argv[2];
    char *output = argv[3];
    //clock_t /*IOStart, IOStop,*/ SortStart, SortStop;
    long no_of_comp = 0;
    if (type[1] == 'a') {
        int size = 0;
        long *array = Array_Load_From_File(input,&size);
        //SortStart = clock();
        Array_Shellsort(array,size,&no_of_comp);
        //SortStop = clock();
        int int_copied = 0;
        int_copied = Array_Save_To_File(output,array,size);

    }
    else {
        int NodesCopied = 0;
     
        Node *head = List_Load_From_File(input);
       
        head = List_Shellsort(head, &no_of_comp);
        
        NodesCopied = List_Save_To_File(output,head);
        free_node(head);
      
    }
    printf("No. of comparisons = %ld\n",no_of_comp);
    
    return EXIT_SUCCESS;
}
