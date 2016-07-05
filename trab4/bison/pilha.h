#ifndef PILHA_H
#define PILHA_H

#include <stdlib.h>

struct pilha;
typedef struct pilha Pilha;

struct pilha {
	int value;
	Pilha* prox;
};

Pilha* pilha_valores;

int pop();
void push(int value);

#endif
