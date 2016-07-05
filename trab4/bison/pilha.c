#include "pilha.h"

int pop() {
  Pilha* p = pilha_valores;
  int value = p->value;
  pilha_valores = p->prox;
  free(p);
  return value;
}
void push(int value) {
  Pilha* p = malloc(sizeof(Pilha));
  p->value = value;
  p->prox = pilha_valores;
  pilha_valores = p;
}
