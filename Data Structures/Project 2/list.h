#ifndef LIST_H
#define LIST_H
#include <stdbool.h>
#define SIZE 3

typedef struct Node 
{
  int array[SIZE] ;
  struct Node * next; // next pointer 
  struct Node * prev; // previous pointer
} ListNode;

typedef struct 
{
  ListNode * head; // head pointer
  ListNode * tail; // tail pointer
}List;

bool read_file(char * filename, List * post_list);
void addnode(List* post_list, int val1, int val2, int val3);
void deleteList( List *lp);
//void deleteNode(ListNode * lp);
#endif


