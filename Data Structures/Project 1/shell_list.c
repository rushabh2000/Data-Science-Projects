
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include "shell_list.h"

#define INT_MIN -1000000000
static Node* swapper(Node* ptr1, Node* end) {
  
 
  if (ptr1 == NULL) {
      Node * ptr2 = end;
      Node * ptr3 = end->next;
      ptr2->next = end->next->next;
      
    ptr3->next = end;
    return ptr3;
  }

  Node * ptr2 = ptr1->next; // fe
    bool counta =0; // fetops
    
    Node * ptr3 = ptr1->next->next; // le
    bool counta2 =0;
  Node * ptr4 = ptr1->next->next->next; // ln
  
  

    if(ptr2 == end)
    {
        counta = 1;
    }
  
    if(ptr3 == end)
    {
        counta2 = 1;
    }

  ptr1->next = ptr3;
  ptr3->next = ptr2;
  ptr2->next = ptr4;

    
return counta ? ptr3 : counta2 ? ptr2 : end;
}

int List_Save_To_File(char *filename, Node *list)
{
 
   
  FILE * fptr = fopen(filename, "wb");
   
  if (fptr == NULL)
  {
      printf("error in writing");
    return false;
  }
    
     int count =0;
  for(Node*temp =list; temp!= NULL; temp = temp->next){
   count += fwrite (&(temp->value),sizeof(long),1,fptr);
     
}
fclose(fptr);
return count;
}

static Node* List_BubbleSort( long *n_comp,Node* head) {
    
    if (head == NULL ){
      return head;
    }
    if (head->next == NULL ){
      return head; // n node
    }
  
    int flag;
  do {
      Node * end  = NULL; // last node
    flag = 0; // false
    
    if ( head->next->value < head->value) {
        flag = 1;
      head = swapper(NULL, head);
      (*n_comp)++;
    }
      
     Node* temp = head; // is prev 1
      
      Node * temp2 = head->next; // is curr1
      
    for (; temp2->next != end; temp = temp2, temp2 = temp2->next) {
      if (temp2->next->value < temp2->value) {
          (*n_comp)++;
        Node * aaja = temp2->next;
        head = swapper( temp, head);
          flag = 1;
        temp2 = aaja;
        
      }
    }
    end = temp2->next;
  } while (flag);
  return head;
}

Node *List_Shellsort(Node *list, long *n_comp) {
 
    Node * aaja = List_BubbleSort(n_comp,list);
    
    return aaja;
}
Node *List_Load_From_File(char *filename)
{
  FILE *fptr;
  
  fptr = fopen(filename,"rb");
  if(fptr == NULL)
  {
    fprintf(stderr, "File error: %s \n",filename);
    return NULL;
  }
    int elems_no; // num_elem
    Node * elems_node = NULL; // node_elem
    long temp; // buffer
    Node *head = NULL;
    
    elems_no = (fread(&temp,sizeof(long),1,fptr));
  if(elems_no == 1)
  {
   elems_node = head =malloc(sizeof(Node));
      elems_node->value = temp;

  while(elems_no == 1){
  elems_no = fread(&temp, sizeof(long), 1,fptr);
  if(elems_no == 1)
  {
   Node * node_next = malloc(sizeof(Node));
   
   elems_node->next = node_next;
    node_next->value = temp;
   elems_node = node_next;

   }
   }
    elems_node->next = NULL;
}

fclose(fptr);
return head;
}
