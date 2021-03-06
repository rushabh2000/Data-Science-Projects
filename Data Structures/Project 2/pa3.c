#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "package.h"
#include"list.h"

int main (int argc, char **argv)
{
  if(argc !=5) // need to update for final outputs
  {
   printf("need more inputs");
   return EXIT_FAILURE;
  }

  List * get_list;
  get_list = malloc(sizeof(List));
  get_list->head = NULL;
  get_list->tail = NULL;
 
  bool chk;
  chk = read_file(argv[1],get_list) ;
  if (chk == EXIT_FAILURE)
  {
    printf("fail to read\n");
    free(get_list);
    return( EXIT_FAILURE);
  }
  // function calls
  Tree * get_tree = buildTree(get_list);
  preOrder(get_tree, argv[2]);
  
  //output 2 dimension section
 // dim_calc(get_tree->root);
  postOrder(get_tree,argv[3]);
  get_coordinates(get_tree->root);
  postOrder2(get_tree,argv[4]);
  //free section 
  deleteList(get_list);
  freeTree(get_tree);
  free(get_list);
  return EXIT_SUCCESS;
}
