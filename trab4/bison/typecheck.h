#ifndef TYPECHECK_H
#define TYPECHECK_H

//Enumeráveis dos tipos usados para checagem de tipos
//Tipos primitivos + VOID, NUMERICO, INDEFINIDO
//VOID: representa um tipo vazio
//NUMERICO: representa um tipo indefinido que deve ser real ou inteiro
//INDEFINIDO: representa um tipo do qual não se pode inferir nada ainda
typedef enum enum_tipos_prim {
        INTEIRO, REAL, INDEFINIDO, CARACTERE, LITERAL, LOGICO, VOID, NUMERICO
} tipos_prim;

//Tipos compostos
typedef enum enum_tipos_cmp {
    LITERAIS = 9, INTEIROS, CARACTERES, LOGICOS, REAIS,
    MATRIZ_LITERAIS, MATRIZ_INTEIROS, MATRIZ_CARACTERES, MATRIZ_LOGICOS, MATRIZ_REAIS
} tipos_cmp;

//Operadores
typedef enum enum_op {
    OP_REL_EQL, OP_REL_INEQL, OP_REL_CMP, OP_ARIT, OP_MOD, OP_BIN, OP_LOG, OP_NOT, OP_UNARY, OP_UNOT
} tipos_op;

//Estrutura de checagem de tipos, usada para criar a árvore de expressões
struct str_fcall_typecheck {
    char* funcao;
    unsigned tipo_esperado;
    unsigned linha_chamada;
    int operacao;
    struct str_fcall_typecheck* esq;
    struct str_fcall_typecheck* dir;
};

typedef struct str_fcall_typecheck type_check;

//Estrutura que controla todas as árvores de checagem de tipo
struct str_fcall_typecheck_forest
{
    type_check* tree;
    struct str_fcall_typecheck_forest* prox;
};

typedef struct str_fcall_typecheck_forest type_check_forest;

//Floresta de árvores de tipos das expressões que armazena todas as
//checagens de tipos que precisam ser feitas
type_check_forest* tc_forest;

//Lida com a checagem de tipos em expressões
//Adiciona uma nova checagem de tipo à árvore de checagem de tipos
type_check* new_typecheck(char* funcao, unsigned tipo_esperado, unsigned linha_chamada, int operacao, type_check* esq, type_check* dir);
//Ajusta o tipo de uma checagem para o tipo especificado
void set_expr_type(type_check* expr, unsigned tipo);
//Adiciona a árvore de checagem de tipos à floresta especificada
type_check_forest* add_to_forest(type_check* tree, type_check_forest* forest);
//Faz a verificação de todos as checagens de tipos pendentes
void verify_all_typechecks(type_check_forest* forest);
//Avalia a checagem de tipo na árvore (visita em pós-ordem)
void verify_typecheck(type_check* tree);

//Operações sobre expressões
//Expressões OU e E
unsigned expr_op_log(unsigned t1, unsigned t2, unsigned linha_chamada);
//Expressões >=, >, <, <=
unsigned expr_op_rel_cmp(unsigned t1, unsigned t2, unsigned linha_chamada);
//Expressões =, <>
unsigned expr_op_rel_eqineq(unsigned t1, unsigned t2, unsigned linha_chamada);
//Expressões &, |, ^
unsigned expr_op_bin(unsigned t1, unsigned t2, unsigned linha_chamada);
//Expressões +, -, *, /
unsigned expr_op_arit(unsigned t1, unsigned t2, unsigned linha_chamada);
//Expressão %
unsigned expr_op_mod(unsigned t1, unsigned t2, unsigned linha_chamada);
//Expressão NOT
unsigned expr_op_not(unsigned t1, unsigned linha_chamada);
//Expressão ~
unsigned expr_op_unot(unsigned t1, unsigned linha_chamada);
//Expressões +, - (unários)
unsigned expr_op_unary(unsigned t1, unsigned linha_chamada);
//Expressão :=
unsigned expr_op_attr(unsigned t1, unsigned t2, unsigned linha_chamada);
//Passagem de parâmetros para função
unsigned expr_op_pass(unsigned t1, unsigned t2, unsigned linha_chamada);
//Determina se o tipo é um tipo matriz
unsigned eh_matriz(unsigned tipo);

#endif