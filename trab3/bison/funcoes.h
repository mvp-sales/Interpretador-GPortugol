#include "variaveis.h"
#include "typecheck.h"

//Estrutura que armazena os parâmetros relacionados à chamada de uma função (pré-declaração)
struct str_fcall {
    int nargs;
    unsigned linha_chamada;
    type_check_forest* expr_forest;
    struct str_fcall* prox;
};

typedef struct str_fcall fcall;

//Tabela de símbolos para funções
struct tb_simbolos_funcoes {
    char* nome;
    int aridade;
    unsigned linha_decl;
    unsigned retorno;
    int declarada;
    fcall* fcalls; //Lista de chamadas à função
    unsigned* tipos_esperados;
    hashmap_var hash_var; //tabela de simbolos para variáveis no escopo da função
    struct tb_simbolos_funcoes *prox;
};

typedef struct tb_simbolos_funcoes tbl_funcoes;

//Tabela hash para funções
struct str_hashmap_funcoes {
    tbl_funcoes *tbl_fnc;
};

typedef struct str_hashmap_funcoes* hashmap_fnc;

//Armazena a tabela hash global de funções
hashmap_fnc hashmap_func;

//Operações de funções
//Procura a função especificada na tabela de funções
tbl_funcoes* lookup_fnc(char* nome);
//Insere uma nova função na tabela de símbolos global para funções
tbl_funcoes* insert_fnc(char* nome, unsigned linha_decl, int aridade, unsigned retorno, int declarada, tbl_variaveis* fparams);
//Retorna a tabela de simbolos para variáveis da função
hashmap_var get_fnc_hashmap_var(char* nome);
//Altera o escopo atual para novo escopo
void muda_escopo(char* novo_escopo, char** escopo_atual);

//Lida com a chamada de funções durante o programa
//Adiciona uma nova chamada à função especificada
void new_call(char* funcao, type_check_forest* expr_forest, unsigned linha_chamada);
//Confere se as chamadas que foram realizadas antes da declaração da função
//atendem aos requisitos necessários
void accept_calls(tbl_funcoes* func);
//Se existem ainda chamadas que não foram atendidas (funções não declaradas), retornar a que ocorreu primeiro
tbl_funcoes* all_calls_accepted(hashmap_fnc hash);
//Confere se os tipos de argumentos especificados conferem com os parâmetros da função
void check_params(char* funcao, type_check_forest* args);
