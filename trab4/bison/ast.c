#include "ast.h"

Node* create_node(char* name, int value, int type, int numchildren) {
    Node* n = malloc(sizeof(Node));
    n->value = value;
    n->type = type;
    if (name != NULL) {
        n->name = malloc(1+strlen(name));
        strcpy(n->name, name);
    }
    else {
        n->name = NULL;
    }
    n->numchildren = numchildren;
    if (numchildren != 0) {
    	n->children = malloc(numchildren*sizeof(Node*));
    	int i;
    	for (i = 0; i < numchildren; i++) {
    		n->children[i] = NULL;
    	}
	}
	else {
		n->children = NULL;
	}
    return n;
}

Node* add_child(Node* parent, Node* child) {
	int i;
	for (i = 0; i < parent->numchildren; i++) {
		if (parent->children[i] == NULL) {
			parent->children[i] = child;
            return parent;
		}
	}
	return parent;
}

Node* add_children(Node* parent, AST_FOREST* children) {
    while (children != NULL) {
       add_child(parent, children->node);
       children = children->prox;
    }
    return parent;
}

AST_FOREST* add_to_ast_forest(Node* node, AST_FOREST* forest) {
    AST_FOREST* nf = malloc(sizeof(AST_FOREST)), *f;
    nf->node = node;
    nf->prox = NULL;
    if (forest == NULL)
        return nf;
    f = forest;
    while (f->prox != NULL)
        f = f->prox;
    f->prox = nf;
    return forest;
}