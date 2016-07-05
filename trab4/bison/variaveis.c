#include "variaveis.h"

//Adiciona uma nova variável à lista de variáveis que ainda serão inseridas na tabela hash
tbl_variaveis* add_to_var_list(tbl_variaveis* lista_var, char* nome, unsigned linha_decl, unsigned tipo) {
    tbl_variaveis *p, *q;
    p = malloc(sizeof(tbl_variaveis));
    p->prox = NULL;
    p->nome = malloc(1+strlen(nome));
    strcpy(p->nome, nome);
    p->linha_decl = linha_decl;
    p->tipo = tipo;
    if (lista_var == NULL)
       return p;
    q = lista_var;
    while (q->prox != NULL)
       q = q->prox;
    q->prox = p;
    return lista_var; 
}

//Funde duas filas de variáveis, colocando src no final de dest
tbl_variaveis* merge_var_lists(tbl_variaveis* dest, tbl_variaveis* src) {
    tbl_variaveis* p;
    p = dest;
    while (p->prox != NULL)
        p = p->prox;
    p->prox = src;
    return dest;
}

//Altera os tipos de uma fila de variáveis para o tipo especificado.
void ajustar_tipo(tbl_variaveis* src, unsigned tipo) {
    while (src != NULL) {
        src->tipo = tipo;
        src = src->prox;
    }
}

//Retorna o tamanho da lista de variáveis (usada para determinar aridade de função)
int size(tbl_variaveis* src) {
  int count = 0;
  while (src != NULL) {
    count++;
    src = src->prox;
  }
  return count;
}

//Função de hash
unsigned hash_func(char *s, int len) {
  unsigned h = 0;
  int i;

  for (i = 0; i < len; i++) {
    h += s[i];
    h += (h << 10);
    h ^= (h >> 6);
  }
  h += (h << 3);
  h ^= (h >> 11);
  h += (h << 15);

  return h % HASH_SIZE;
}

//Determina a variável com nome dado existe na tabela de símbolos para variáveis especificada
tbl_variaveis* lookup_var(char* nome, hashmap_var hash) {
	tbl_variaveis* hv;
	unsigned pos;
	pos = hash_func(nome, strlen(nome));
	hv = hash[pos].tbl_var;
	while (hv != NULL) {
		if (strcmp(hv->nome, nome) == 0)
			return hv;
		hv = hv->prox;
	}
	return NULL;
}

//Insere uma variável previamente criada na tabela hash especificada
void insert_var(tbl_variaveis* tbl, hashmap_var hash) {
    tbl_variaveis* elem_found = lookup_var(tbl->nome,hash);
    if (elem_found == NULL) {
        int pos = hash_func(tbl->nome, strlen(tbl->nome));
        tbl_variaveis* tv = hash[pos].tbl_var;
        if (tv == NULL) {
            hash[pos].tbl_var = tbl;
            tbl->prox = NULL;
        }
        else {
            tbl->prox = tv;
            hash[pos].tbl_var = tbl;
        }
    }
    else {
        fprintf(stderr, "Erro semantico na linha %d: variavel '%s' ja foi declarada na linha %d\n", tbl->linha_decl, tbl->nome, elem_found->linha_decl); 
        exit(1);
    }
}

//Insere as múltiplas variáveis na hashmap especificada
void insert_multi_var(tbl_variaveis* fila, hashmap_var hash) {
	tbl_variaveis* tv;
    while (fila != NULL) {
        tv = fila->prox;
		insert_var(fila, hash);
		fila = tv;
	}
}