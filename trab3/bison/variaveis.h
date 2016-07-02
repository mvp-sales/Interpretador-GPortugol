#include <stdio.h>
#include <stdlib.h>
#include <string.h>

//Tamanho das tabelas hash
#define HASH_SIZE 17

//Tabela de símbolos para variáveis
struct tb_simbolos_var {
    char* nome;
    unsigned tipo;
    unsigned linha_decl;
    struct tb_simbolos_var *prox;
};

typedef struct tb_simbolos_var tbl_variaveis;

//Tabela hash para variáveis
struct str_hashmap_var {
    tbl_variaveis *tbl_var;
};

typedef struct str_hashmap_var* hashmap_var;

//Função de hash
unsigned hash_func(char *s, int len);

//Operações de variáveis
//Determina a variável com nome dado existe na tabela de símbolos para variáveis especificada
tbl_variaveis* lookup_var(char* nome, hashmap_var hash);
//Insere a variável previamente declarada na tabela de simbolos para variáveis especificada
void insert_var(tbl_variaveis* tbl, hashmap_var hash);
//Insere as múltiplas variáveis na tabela hash especificada
void insert_multi_var(tbl_variaveis* fila, hashmap_var hash);

//Adiciona uma nova variável à lista de variáveis que ainda serão inseridas na tabela hash
tbl_variaveis* add_to_var_list(tbl_variaveis* lista_var, char* nome, unsigned linha_decl, unsigned tipo);
//Funde duas filas de variáveis, colocando src no final de dest.
tbl_variaveis* merge_var_lists(tbl_variaveis* dest, tbl_variaveis* src);
//Altera os tipos de uma fila de variáveis para o tipo especificado
void ajustar_tipo(tbl_variaveis* src, unsigned tipo);
//Retorna o tamanho da lista de variáveis (usada para determinar aridade de função)
int size(tbl_variaveis* src);

//Armaazena a tabela hash de varíáveis usada unicamente pelo bloco principal
hashmap_var hashmap_var_bloco_principal;
