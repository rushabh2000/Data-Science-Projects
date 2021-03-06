#ifndef PACKAGE_H
#define PACKAGE_H
#include<stdio.h>
#include<stdlib.h>
#include<string.h>

#include "list.h"
typedef struct tnode
{
  struct tnode *left;
  struct tnode *right;
  int arr[5]; 
} TreeNode;

typedef struct trnode
{
  TreeNode * root;
} Tree;

TreeNode * create_tree (int box_no, int width, int height);///int box_no, int width, int height);
TreeNode * buildtree(List * post_list);
Tree * buildTree (List * post_list);
void preOrder(Tree * tr, char * filename);
void freeTree(Tree * tr);
void postOrder(Tree * tr, char *filename);
void get_coordinates(TreeNode * tr);
void postOrder2(Tree * tr, char *filename);
void postOrderNode2(TreeNode * tn, FILE *fptr);

#endif

