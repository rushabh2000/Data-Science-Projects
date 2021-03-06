#include "list.h"
#include <stdio.h>
#include<stdlib.h>
#include<string.h>

bool read_file(char *filename, List * post_list)
{
  FILE *fptr  = fopen(filename,"r");
  if(fptr == NULL){
  return EXIT_FAILURE;
  }
  fseek(fptr,0,SEEK_END);
  if(ftell(fptr) == 0)
  {
     printf("file is empty\n");
     fclose(fptr);
     return EXIT_FAILURE;
 }
  fseek(fptr,0,SEEK_SET);
  int x =0;
  int y =0;
  int val1 = 0;
  int val2 = 0;
  int val3 =0; 
  char val=0;
  while(x != -1)
  {
   x = fscanf(fptr,"%d(%d,%d)\n",&val1,&val2,&val3);
   if( x == 3)
   {
    addnode(post_list,val1,val2,val3);
   }
   else
   {
    y = fscanf(fptr,"%c\n",&val);
    if( y == 1){
    addnode(post_list,(int)(val),0,0);
   }
   }
   }  
 fclose(fptr); 
 return EXIT_SUCCESS ;
}
void addnode(List * post_list,int val1, int val2, int val3)
{
  if(post_list == NULL)
  {
   return;
   }
  
  ListNode * newNode = malloc(sizeof(ListNode));
  newNode->next = NULL;
  newNode->prev = NULL;
  //newNode->array = NULL;
  if(newNode == NULL)
  {
    return;
  }
  if(post_list->head == NULL)
  {
    post_list->head = post_list->tail = newNode;
  }
  else{
  
  newNode->prev = post_list->tail;
  post_list->tail->next = newNode;
  post_list->tail = newNode;
  } 
  newNode->array[0] = val1;
  newNode->array[1] = val2;
  newNode->array[2] = val3;
// printf("%d\n",newNode->array[0]);
}

void deleteList(List * lp)
{
  List * ptr = lp;
 // if(ptr->head == NULL)
  //{
  //  return;
  //}
  if(ptr == NULL)
 {
   return;
 }
   ListNode * temp = ptr->head;

  while((temp->next) != NULL)
  {
   temp = temp->next;

    free(ptr->head);
	ptr->head = temp;    
    
}
free(temp); 
}
  


