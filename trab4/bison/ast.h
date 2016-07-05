#ifndef AST_H
#define AST_H

#include <stdlib.h>
#include <string.h>
#include <stdio.h>

enum tipo_node {
  OP_UPLUS, OP_UMINUS, BLOCO
};

struct str_node;
typedef struct str_node Node;

struct str_node {
  int value;
  char* name;
  int type;
  int numchildren;
  struct str_node** children;
};

struct astforest;
typedef struct astforest AST_FOREST;

struct astforest {
	Node* node;
	AST_FOREST* prox;
};

Node* bloco_principal;

Node* create_node(char* name, int value, int type, int numchildren);
Node* add_child(Node* parent, Node* child);
Node* add_children(Node* parent, AST_FOREST* children);
AST_FOREST* add_to_ast_forest(Node* node, AST_FOREST* forest);

#endif
