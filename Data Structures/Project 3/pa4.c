#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include<limits.h>
#include "hbt.h"
void printPreorder(Tnode* root,FILE *fptr)
{
     if (root == NULL)
          return;
  
     /* first print data of node */
     
    if(root->left == NULL && root->right == NULL)
    
      root->balance = 0;
    
    else if(root->left == NULL && root->right != NULL)
      root->balance =1;
    else if(root->left != NULL && root->right == NULL)
      root->balance =2;
    else
      root->balance = 3;
    
    fwrite(&root->key,sizeof(int), 1,fptr);
    fwrite(&root->balance,sizeof(char), 1,fptr);
     
     /* then recur on left sutree */
    printPreorder(root->left,fptr);
  
     /* now recur on right subtree */
    printPreorder(root->right,fptr);
}

void deleteTreeNode(Tnode * tr)
{
  if (tr == NULL)
    {
      return;
    }
  deleteTreeNode (tr -> left);
  deleteTreeNode (tr -> right);
  free (tr);
}
Tnode* max_val(Tnode* node) // to find the immediate predecessor
{
    Tnode* curr = node;
  
    /* loop down to find the leftmost leaf */
    while (curr->right != NULL)
    {
        curr = curr->right;
    }
   // int tmp = curr->key;
   // curr = NULL;
    //return (tmp);
    return curr;
}


int max_finder(Tnode* node)
{
    if (node == NULL)
      return INT_MIN;
  
    int node_val = node->key;
    int right = max_finder(node->right);
    int left = max_finder(node->left);
    
    if (left > right)
    {
      right = left;
    }
    if(node_val > right)
    {
        right = node_val;
    }
    return right;
}
int min_finder(Tnode* node)
{
    if (node == NULL)
      return INT_MIN;
  
    int node_val = node->key;
    int right = max_finder(node->right);
    int left = max_finder(node->left);
    
    if (left < right)
    {
      right = left;
    }
    if(node_val < right)
    {
        right = node_val;
    }
    return right;
}

Tnode * build_tree(FILE *fptr)
{
    Tnode* node = (Tnode *)malloc(sizeof(Tnode));
    fread(&node->key, sizeof(int),1,fptr);
    fread(&node->balance,sizeof(char),1,fptr);
    
    if (node->balance == 0)
    {
        node->left = NULL;
        node->right = NULL;
    }
    
    if(node->balance == 1)
    {
           node->right = build_tree(fptr);
        node->left = NULL;
        
    }
    
    if(node->balance == 2)
    {
        node-> left = build_tree(fptr);
        node->right = NULL;
    }
    
    if(node -> balance == 3)
    {
        node->left = build_tree(fptr);
        node->right = build_tree(fptr);
    }
    return node;
}


int bst_checker(Tnode* node)
{
    if(node == NULL)
    {
        return 1;
    }
    
    if(node->balance == 2 && node->key < max_finder(node->left))
    {
       return 0;
    }
         
    if(node->balance == 1 && node->key >= max_finder(node->right))
    {
        return 0;
    }
    
    if(node->balance == 3 && node->key >= max_finder(node->right) &&  node->key < min_finder(node->left))
      {
         return 0;
      }
    
    if( (bst_checker(node->left) ==0) || (bst_checker(node->right) == 0))
    {
        return 0;
    }
    return 1;
}


int balance_checker( int* height,Tnode* root)
{
    /* lh --> Height of left subtree
     rh --> Height of right subtree */
    int rh =0;
    int lh =0;
    int r =0;
    int  l =0;

  
    if (root == NULL) {
        *height = 0;
        return 1;
    }
  
    /* Get the heights of left and right subtrees in lh and rh
    And store the returned values in l and r */
    r = balance_checker(&rh,root->right);

    l = balance_checker(&lh,root->left);

  
    /* Height of current node is max of heights of left and
     right subtrees plus 1*/
    *height = (lh > rh ? lh : rh) + 1;
  
    /* If difference between heights of left and right
     subtrees is more than 2 then this node is not balanced
     so return 0 */
    if (abs(lh -rh) >= 2)
        return 0;
  
    /* If this node is balanced and left and right subtrees
    are balanced then return true */
    else
        return l && r;
}

bool eval(char *filename)
{
    int input_check;
    int height =0;
    
    FILE *fptr  = fopen(filename,"rb");
    if(fptr == NULL){
    printf("-1,0,0\n");
    fclose(fptr);
    return false;
    }
    
    int tmp1;
    char tmp2;
    unsigned long  val1;
    unsigned long val2;
    
    val2 = fread(&tmp1, sizeof(int),1,fptr);
    val1 = fread(&tmp2,sizeof(char),1,fptr);
    fseek(fptr,0,SEEK_SET);
    if(val1 == 1 && val2 ==1)
    {
      input_check = 1;
    Tnode * root = build_tree(fptr);
    int bst_check = bst_checker(root);
    int balance_check = balance_checker(&height,root);
    printf("%d,%d,%d\n",input_check,bst_check,balance_check);
    deleteTreeNode(root);

    }
    else
    printf("0,0,0");
   
    fclose(fptr);
    return true;
}
// eval done here

Tnode* get_node(int key)
{
     Tnode* node = (Tnode*)malloc(sizeof(Tnode));
    node->key  = key;
    node->left   = NULL;
    node->right  = NULL;
    node->balance = 0; // unsure of what to initalize to
    return(node);
}
int height(Tnode* node)
{
   if (node==NULL)
       return 0;
   else
   {
       /* compute the depth of each subtree */
      
     
        int lDepth = height(node->left);
        int rDepth = height(node->right);
       

       if (lDepth > rDepth)
           return(lDepth+1);
       else return(rDepth+1);
   }
}
int get_balance(Tnode *node)
{
    if (node == NULL)
    {
        return 0;
    }
    return (height(node->left) - height(node->right));
}
Tnode* rightRotate(Tnode *y)
{
    Tnode *x = y->left;
    Tnode *T2 = x->right;
  
    // Perform rotation
    x->right = y;
    y->left = T2;
    //return;
    return x;
}
  

Tnode* leftRotate(Tnode *x)
{
    
    Tnode *y = x->right;
    Tnode *T2 = y->left;
    
    // Perform rotation
    y->left = x;
    x->right = T2;
  

    // Return new root
   return y;
}

void rotations (Tnode * root)
{
    if(root == NULL)
    {
        return;
    }
    rotations(root->left);
    rotations(root->right);
    

    
    if ((root->balance == 2) && (root->left->balance == 1)){
        
          rightRotate(root);
          root->balance = 0;
          root->left->balance = 0;
       }
    
    if ((root->balance == -2) && (root->right->balance == -1))
           {
            leftRotate(root);
          root->balance = 0;
          root->right->balance = 0;
                   
           }
    
    if ((root->balance == 2) && (root->left->balance == -1)){
    Tnode * curr = root->left->right;
    leftRotate(root->left);
    root->left = curr;
    rightRotate(root);
        
        
        if (curr->balance == 0) {// child is inserted node q
                root->balance = 0;
              root->left->balance = 0;
               }
               else{
              if (curr->balance == 1){ // ori. left subtree of curr
                root->balance = -1; // contains q
                  root->left->balance = 0;}
               
              else // ori. right subtree of curr
              {
              root->balance = 0; // contains q
              root->left->balance = 1;
              curr->balance = 0; // new root is balanced
              }
               }}
        
        //balances
        if ((root->balance == -2) && (root->right->balance == 1))
        {
         Tnode *curr = root->right->left;
         rightRotate(root->right);
         root->right = curr;
         leftRotate(root);
            
            if (curr->balance == 0) {// curr is inserted node q
             root->balance = 0;
           root->right->balance = 0;
            }
            else{
             if (curr->balance == -1)
             {// ori. right subtree of curr
             root->balance = 1; // contains q
             root->right->balance = 0;
             }
             else // ori. left subtree of curr
            {
         root->balance = 0; // contains q
         root->right->balance = -1;
         curr->balance = 0; // new root is balanced
         }}}
        
    return;
    }
    
void update_balance(Tnode *root)
{
    if(root == NULL)
    {
        return;
    }
    update_balance(root->left);
    update_balance(root->right);
    
    if(root != NULL && root->left != NULL && root->left->left != NULL)
    {
        root->balance = 2;
        root->left->balance = 1;
        root->left->left->balance = 0;
         return;
    }
    
    if(root != NULL && root->right != NULL && root->right->right != NULL)
    {
        root->balance = -2;
        root->right->balance = -1;
        root->right->right->balance = 0;
         return;
    }
    
    if(root != NULL && root->left != NULL && root->left->right != NULL)
    {
        root->balance = 2;
        root->left->balance = -1;
        root->left->right =0;
         return;
    }
    if(root != NULL && root->right != NULL && root->right->left != NULL)
    {
        root->balance = -2;
        root->left->balance = 1;
        root->left->right =0;
        return;
    }

    
    return;
}



Tnode* delete(int key, Tnode* root)
{
    
    if (root == NULL)
    {
        return root;
    }
    
    if( key > root->key ){
           root->right = delete(key, root->right);
    }
    else if (key < root->key){
           root->left = delete(key,root->left);
    }
    else
    {
     if ((root->right == NULL) || (root->left == NULL))
    {
       Tnode *tmp = root->left ? root->left :root->right;
        
        if(tmp == NULL) // has no children in node
        {
            tmp = root;
            root =  NULL;
        }
        else
        *root = *tmp;
        free(tmp);
    }
     else{
    //int vals = max_val(root->left);// 2 childrne case
    //root->key = vals;
         
         Tnode *pre_decessor  = max_val(root->left);// 2 childrne case
         root->key = pre_decessor->key;
         
         root->left = delete(pre_decessor->key,root->left);
     }}
    
    // previous code was here rushabh
      return root;
}
Tnode * insert(int key, Tnode * tree_root)
{
    Tnode* ya = tree_root;
    Tnode *curr = tree_root;
    Tnode *pya =  NULL;
    Tnode*pcurr = NULL;
    Tnode * q = NULL;
    
    while (curr != NULL)
    {
     if (key <= curr->key)
     {
         q = curr->left;
     }
     else
     {
         q = curr->right;
     }
     if (q != NULL && q->balance != 0)
     {
         pya = curr;
         ya = q;
     }
     pcurr = curr;
     curr = q;
 }
    q = get_node(key);
    q->balance = 0;
    if (pcurr == NULL){
     tree_root = q;
    }
    else
    {
       if (key <= pcurr->key)
       {
         pcurr->left = q;
       }
       else
         pcurr->right = q;
    }

    curr = ya;
    
    while (curr != q)
    {
     if (key <= curr->key)
     {
     curr->balance += 1;
     curr = curr->left;
     }
     else
     {
     curr->balance -= 1;
     curr = curr->right;
     }}
    // check if balancing is required
    if ((ya->balance < 2) && (ya->balance > -2))
    {
     return tree_root;
    }
    // find the child into which q is inserted
    Tnode * child = NULL;
    if (key <= ya->key){
     child = ya->left;
    }
    else
    {
     child = ya->right;
    }
    
    // balance section
    
    if ((ya->balance == 2) && (child->balance == 1)){
       curr = child;
       rightRotate(ya);
       ya->balance = 0;
       child->balance = 0;
    }
        if ((ya->balance == -2) && (child->balance == -1))
        {
        curr = child;
       leftRotate(ya);
       ya->balance = 0;
       child->balance = 0;
        }
    // ya and child are unbalanced in opp. Directions
    if ((ya->balance == 2) && (child->balance == -1))
    {
     curr = child->right;
     leftRotate(child);
     ya->left = curr;
     rightRotate(ya);
        if (curr->balance == 0) {// child is inserted node q
         ya->balance = 0;
       child->balance = 0;
        }
        else{
       if (curr->balance == 1){ // ori. left subtree of curr
         ya->balance = -1; // contains q
           child->balance = 0;}
        
       else // ori. right subtree of curr
       {
       ya->balance = 0; // contains q
       child->balance = 1;
       curr->balance = 0; // new root is balanced
       }
        }}
    
    if ((ya->balance == -2) && (child->balance == 1))
    {
     curr = child->left;
     rightRotate(child);
     ya->right = curr;
     leftRotate(ya);
        
        if (curr->balance == 0) {// curr is inserted node q
         ya->balance = 0;
       child->balance = 0;
        }
        else{
         if (curr->balance == -1)
         {// ori. right subtree of curr
         ya->balance = 1; // contains q
         child->balance = 0;
         }
         else // ori. left subtree of curr
        {
     ya->balance = 0; // contains q
     child->balance = -1;
     curr->balance = 0; // new root is balanced
     }}}
    if (pya == NULL)
    {
     tree_root = curr;
    }
    else{
     if (key <= pya->key)
     {
         pya->left = curr;
     }
     else{
        pya->right = curr;
     }}
        return tree_root;
}
    
bool bst_tree(char *filename,char*filename2)
{
    FILE *fptr = fopen(filename,"rb");
    if(fptr == NULL){
        printf("%d\n",-1);
        fclose(fptr);
        return false;
    }
    int tmp1;
    char tmp2;
    unsigned long  val1 ;
    unsigned long val2;
    Tnode *root = NULL;
   val1 = fread(&tmp1,sizeof(int),1,fptr);
   val2 = fread (&tmp2,sizeof(char),1,fptr);
   root = get_node(tmp1);

    do{
    val1 = fread(&tmp1,sizeof(int),1,fptr);
    val2 = fread (&tmp2,sizeof(char),1,fptr);
    
          
            if(val1 == 1 && val2 ==1){
            if (tmp2 == 'i' ){
                root = insert(tmp1,root);
           }
            if(tmp2 == 'd')
              root = delete(tmp1,root);
              
        }
       
    }while( val1 ==1 && val2 ==1);
    
   FILE *fptr2 = fopen(filename2,"wb");
    if(fptr2 == NULL){
           fclose(fptr);
           return false;
       }

    printPreorder(root,fptr2);
    deleteTreeNode(root);
    fclose(fptr);
    fclose(fptr2);
    printf("%d\n",1);
    return true;
}



    // insert code here...
    int main(int argc,char ** argv)
    {
       if (argc < 2)
      {
         return EXIT_FAILURE;
      }
       char *type = argv[1];
       char *input = argv[2];
       char *output = argv[3];
       
      bool option = strcmp(type,"-b");
        
    if(option){
        eval(input);

    }
    else {
        
        bst_tree(input,output);
        
    }
    return 0;
}
