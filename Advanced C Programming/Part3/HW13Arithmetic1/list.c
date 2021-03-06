// ***
// *** You MUST modify this file
// ***

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "list.h"

#ifdef TEST_READLIST
// read line by line from the input file
// each line shorter than WORDLENGTH (including '\n' and '\0')
// arithlist should have memory to store head and tail
// If arithlist is NULL, return false
// If fopen fails, return false
// If a line is too long,
//    free memory of the list
//    fclose
//    return false
// If everything is fine
//    fclose
//    arithlist points to the head and tail of the list
//    return true
bool readList(char * filename, List * arithlist)
{
   FILE *fptr;
   
   fptr = fopen(filename,"r");
   
   if(fptr == NULL)

   {
    return false;
   }
   char temp[WORDLENGTH];
   while((fgets(temp,WORDLENGTH,fptr)) != NULL)
   { 
    if(temp[strlen(temp)-1] == '\n')
    {
     addNode(arithlist, temp);
    }
   else {
     deleteList(arithlist);
     fclose(fptr);
     return false;
    }
   }
 return true;
}
#endif

#ifdef TEST_DELETELIST
// If arithlist is NULL, do nothing
// release the memory of every node in the list
// release the memory of the list 
void deleteList(List * arithlist)
{
 if(arithlist == NULL)
   {
     return; 
   }
  ListNode* i;
  i = arithlist->head;
  ListNode* todelete;
   while(i != NULL)
  {
   todelete = i;
   i = i->next;
   deleteNode(arithlist, todelete);
  }
  free(arithlist);
}
#endif

#ifdef TEST_ADDNODE
// Input: 
// arithlist stores the addresses of head and tail
// If arithlist is NULL, do nothing
// word is the word to be added
//
// Output:
// a ListNode is added to the end (become tail)
//
// allocate memory for a new ListNode
// copy word to the word attribute of the new ListNode
// insert the ListNode to the list
void addNode(List * arithlist, char * word)
{
  if (arithlist == NULL) return;
  ListNode * newNode = malloc(sizeof(ListNode));
  if (arithlist->head == NULL) {
    arithlist->head = arithlist->tail = newNode;
  } else {
  newNode->prev = arithlist->tail;
  arithlist->tail->next = newNode;
  arithlist->tail = newNode;
  }
  strcpy(newNode->word, word); 
}
#endif

#ifdef TEST_DELETENODE
//  Input:
// arithlist stores the addresses of head and tail
// If arithlist is NULL, return false
// If the list is empty (head and tail are NULL), return false
// ln is the node to be deleted
// If ln is not in the list, return false
// 
// Output:
// arithlist stores the addresses of head and tail
//   after ln is deleted
// return true.
//
// Be careful about delete the first or the last node
bool deleteNode(List * arithlist, ListNode * ln)
{
  if(arithlist == NULL)
 {
  return false;
 }

  if((arithlist->head == NULL) && (arithlist->tail == NULL)) 
  {
   return false;
  }
  
  bool seen = false;
  ListNode* prev = NULL, *next;
  if (arithlist->head == ln) {
    next = ln->next;
    if (next != NULL)
    next->prev = NULL;

    free(ln);
    arithlist->head = next;
    return true;
  }
  for(ListNode*curr = arithlist->head; curr!=NULL;curr = curr->next)
  {
   if(curr == ln){
   seen = true;
   prev = curr->prev;
   prev->next = ln->next;
   if (prev->next != NULL) {
     prev->next->prev = prev;
   }else
     arithlist->tail = prev;
   free(ln);
   return true;
  }  }
  return seen;
}
#endif

