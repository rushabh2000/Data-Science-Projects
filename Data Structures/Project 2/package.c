#include<stdio.h>
#include<stdlib.h>
#include<string.h>
#include"package.h"
#include"list.h"

TreeNode * create_tree (int box_no, int width, int height)//int box_no, int width, int height) // creates treenode 
{
  TreeNode *ptr = malloc(sizeof(TreeNode));
  ptr-> left = NULL;
  ptr->right = NULL;
  ptr->arr[0] = box_no;//box_no;
  ptr->arr[1] = width;//width;
  ptr->arr[2] = height;//height;
  ptr-> arr[3] = 0; // x coordinates
  ptr->arr[4] = 0; // y coordinates
  return ptr;
}

Tree * buildTree (List * post_list)
{
  Tree*maintree = (Tree*)malloc(sizeof(Tree));
  maintree->root = buildtree(post_list);

return maintree;
}
TreeNode * buildtree(List * post_list)
{
 
  if(post_list->tail == NULL)
  {
    return NULL;
  }
  List * temp_list; // temp variable to store list pointer
  temp_list = post_list; // make temp list point to post list
  //TreeNode * tree;
 
  
  if(((((char)(post_list->tail->array[0])) == 'H')| (((char)(post_list->tail->array[0])) == 'V') ) &( (post_list->tail->array[1]) == 0 ) & ((post_list->tail->array[2]) ==0))
  {
       
     TreeNode *tree = create_tree(post_list->tail->array[0],0,0);
     if(tree == NULL) 
     {
      return NULL;
      }

     temp_list->tail = post_list->tail->prev;
     tree->right = buildtree(temp_list);
     temp_list->tail = post_list->tail->prev;
     tree->left = buildtree(post_list);
    return tree;
  }
  
  TreeNode *tree = create_tree(post_list->tail->array[0],post_list->tail->array[1],post_list->tail->array[2]);
   return tree;

}

static void preOrderNode(TreeNode * tr, FILE * fptr)
{
  if (tr == NULL)
    {
      return;
    }
 // printf("%d\n",tr->arr[0]);
 if(((((char)(tr->arr[0])) == 'H')| (((char)(tr->arr[0])) == 'V')) & ((tr->arr[1]) == 0) & ((tr->arr[2]) ==0))// could replace with just not 0 for arr[2][1]
  {
  fprintf(fptr,"%c\n", tr ->arr[0]);
  }

  else
  {
  fprintf(fptr,"%d(%d,%d)\n", tr->arr[0],tr->arr[1],tr->arr[2]);
  }
  preOrderNode(tr->left, fptr);
  preOrderNode(tr->right, fptr);
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
static int max(int val1, int val2)
{
  return (val1 > val2 ) ? val1 : val2 ;
}

static void dim_calc(TreeNode * tr, FILE *fptr)
{
  if(tr == NULL)
  {
     return;
  }

  dim_calc(tr->left,fptr); 
  dim_calc(tr->right,fptr);

    if((tr->arr[2] != 0) & (tr->arr[1] != 0 ))
   {
    fprintf(fptr,"%d(%d,%d)\n", tr->arr[0],tr->arr[1],tr->arr[2]);
   }
 else{
 if((((char)(tr->arr[0])) == 'H')) // just verify condition
  {
    tr->arr[1] = max(tr->left->arr[1],tr->right->arr[1]);// the max width for h orientation
    tr->arr[2] = tr->left->arr[2] + tr->right->arr[2]; // add the heights for the h orientation
    fprintf(fptr,"%c(%d,%d)\n", tr->arr[0],tr->arr[1],tr->arr[2]);
    tr->arr[0] = -2;  // 1 is for H
  }

  if((((char)(tr->arr[0])) == 'V'))
  {
    tr->arr[1] = tr->left->arr[1] + tr->right->arr[1];   
    tr->arr[2] =  max(tr->left->arr[2],tr->right->arr[2]);
    fprintf(fptr,"%c(%d,%d)\n", tr->arr[0],tr->arr[1],tr->arr[2]);
    tr->arr[0] = -4; // 2 is for V
}}
}

void postOrder(Tree * tr, char * filename)
{
  if(tr == NULL)
  {
   return;
  }
  FILE * fptr = fopen(filename, "w");
  dim_calc(tr->root,fptr);
  fclose(fptr);
}
void get_coordinates(TreeNode * tr)
{
  if( tr == NULL)
  {
     return;
  }
 
   
  if((((tr->arr[0])) == -4)) // can modify the vals for v and h coordinates to escape  1k test case with ascii anomaly

  {
    //get_coordinates(tr->left);
   // get_coordinates(tr->right);  
      
    tr->right->arr[3] = tr->arr[3];
    tr->right->arr[4] = tr->arr[4];  
    tr->left->arr[3] = tr->arr[3];
    tr->left->arr[4] = tr->arr[4];
 

    tr->right->arr[3] = tr->right->arr[3] + tr->left->arr[1]; // increase right by width
  } 


  if((((tr->arr[0])) == -2))

  { 
    
    tr->right->arr[3] = tr->arr[3];
    tr->right->arr[4] = tr->arr[4];  
    tr->left->arr[3] = tr->arr[3];
    tr->left->arr[4] = tr->arr[4];

    tr->left->arr[4] = tr->left->arr[4] + tr->right->arr[2]; // increase left by height
      
  }
      get_coordinates(tr->right);
     get_coordinates(tr->left);

}
void postOrderNode2(TreeNode * tn, FILE *fptr)
{
  if(tn == NULL)
  {
   return;
  }
  
  postOrderNode2(tn->left,fptr);
  postOrderNode2(tn->right,fptr);

   if(((tn->arr[0]) != -4) && ((tn->arr[0]) != -2))
  {
  fprintf(fptr,"%d((%d,%d)(%d,%d))\n", tn->arr[0],tn->arr[1],tn->arr[2],tn->arr[3],tn->arr[4]);
  }
}

void postOrder2(Tree * tr, char * filename)
{
  if(tr == NULL)
  {
   return;
  }
  FILE * fptr = fopen(filename, "w");
  postOrderNode2(tr->root,fptr);
  fclose(fptr);
}

