// ***
// *** You MUST modify this file
// ***

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include "tree.h"

// DO NOT MODIFY FROM HERE --->>>
Tree * newTree(void)
{
  Tree * t = malloc(sizeof(Tree));
  t -> root = NULL;
  return t;
}

void deleteTreeNode(TreeNode * tr)
{
  if (tr == NULL)
    {
      return;
    }
  deleteTreeNode (tr -> left);
  deleteTreeNode (tr -> right);
  free (tr);
}

void freeTree(Tree * tr)
{
  if (tr == NULL)
    {
      // nothing to delete
      return;
    }
  deleteTreeNode (tr -> root);
  free (tr);
}


// <<<--- UNTIL HERE

// ***
// *** You MUST modify the follow function
// ***
//
int finder(int array[],int begin, int end, int value);
TreeNode* branches(int vals);
TreeNode * buildSubTree(int * inArray, int * postArray,int start,int size, int* p )
{
if (start > size)
{
return NULL;
}
  

   TreeNode *tree = branches(postArray[*p]);
   (*p)--;
  if(start == size)
  {
   return tree;
  }
  
  int index = finder(inArray,start,size,tree->value);
  tree->right = buildSubTree(inArray,postArray,index + 1,size,p);
  tree->left = buildSubTree(inArray,postArray,start,index - 1,p);

  return tree;

}

#ifdef TEST_BUILDTREE
Tree * buildTree(int * inArray, int * postArray, int size)
{
  int n = size - 1;
 
  Tree *maintree = (Tree*)malloc(sizeof(Tree)); 
  maintree->root = buildSubTree(inArray,postArray,0, size - 1, &n);
  //printPath(maintree,inArray[0]);
  
return maintree;
}
#endif
int finder(int array[], int begin, int end, int value)
{
  int i = 0;
for( i = begin; i <= end;i++)
{
  if(array[i] == value)
  {
     break;
  }
}
return i;
}

TreeNode* branches (int vals)
{
 TreeNode *children = malloc(sizeof(TreeNode));
 children->value = vals;
 children->left = NULL;
 children->right = NULL;
 return children;
}
#ifdef TEST_PRINTPATH
void printPath(Tree * tr, int val)
{
 TreeNode * tn = tr->root;
 int array[50] = {0};
 int i = 0;
 while(tn != NULL)
 {
  array[i] = tn->value; 
  i++;
  tn = tn->left;
  }

 for(int p=i;p>=0;p--)
 {
  if(array[p] != 0)
  {
   printf("%d\n",array[p]);
  }
 } 
}
#endif
