// ***
// *** You MUST modify this file
// ***

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tree.h"

// DO NOT MODIFY FROM HERE --->>>
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

static void preOrderNode(TreeNode * tn, FILE * fptr)
{
  if (tn == NULL)
    {
      return;
    }
  fprintf(fptr, "%d\n", tn -> value);
  preOrderNode(tn -> left, fptr);
  preOrderNode(tn -> right, fptr);
}

void preOrder(Tree * tr, char * filename)
{
  if (tr == NULL)
    {
      return;
    }
  FILE * fptr = fopen(filename, "w");
  preOrderNode(tr -> root, fptr);
  fclose (fptr);
}
// <<<--- UNTIL HERE

// ***
// *** You MUST modify the follow function
// ***

// Consider the algorithm posted on
// https://www.geeksforgeeks.org/construct-a-binary-tree-from-postorder-and-inorder/
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
