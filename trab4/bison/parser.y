%code requires {
    #include "ast.h"
    #include "funcoes.h"
    #include "runner.h"
}

%{

int yylex(void);
void yyerror(char const *s);
int main();
unsigned assoc_type(int type);

int line_num = 1;
char* escopo;


%}

%union {
    //Usada para detalhar o tipo de primitivos
    unsigned tp_expr;
    //Usada para detalha o tipo/valor de constantes, usado para AST
    Node* node;
    //Usada para montar as árvores de expressões
    //conforme são encontradas
    struct str_expr_typecheck {
        char* funcao; //detalha se há uma função ainda não declarada no nó da árvore
        unsigned tipo;
        unsigned linha_chamada;
        void* expr; //árvore de tipos da expressão
        Node* node; //usado para a criação da AST
    } tp_expr_typecheck;
    //Usada para detalhar identificadores,
    //utilizados por funções/variáveis
    struct struct_identificador {
	    char* label; //nome do identificador
        unsigned linha_decl; //linha em que foi declarado
    } tp_identificador;
    //Usada pelos fargs durante chamadas à função
    struct str_fargs_type {
        int size; //quantidade de argumentos
        void* expr_forest; //floresta das árvores de tipos das expressões que detalha o que
                           //está sendo passado como argumento à função
        AST_FOREST* ast_forest; //usado para a criação da AST
    } fargs_type;
    //Usada para controlar as listas de variáveis pré-inserção
    //nas tabelas hash
    void* lista_var;
};

%error-verbose

%token <tp_identificador> T_IDENTIFICADOR

%token <node> T_STRING_LIT
%token <node> T_CARAC_LIT
%token <node> T_INT_LIT
%token <node> T_REAL_LIT
%token <node> T_KW_VERDADEIRO
%token <node> T_KW_FALSO

%token TP_INTEIRO "inteiro"
%token TP_REAL "real"
%token TP_LITERAL "literal"
%token TP_LOGICO "logico"
%token TP_CARACTERE "caractere"

%token TP_INTEIROS "inteiros"
%token TP_REAIS "reais"
%token TP_LITERAIS "literais"
%token TP_LOGICOS "logicos"
%token TP_CARACTERES "caracteres"

%token OP_REL_EQ "="
%token OP_REL_INEQ "<>"
%token OP_REL_GT ">"
%token OP_REL_GTEQ ">="
%token OP_REL_LT "<"
%token OP_REL_LTEQ "<="

%token OP_ATR ":="

%token OP_LOG_E "e"
%token OP_LOG_OU "ou"
%token OP_LOG_NAO "nao"

%token ALGORITMO "algoritmo"
%token MATRIZ "matriz"
%token VARIAVEIS "variaveis"
%token FIM_VARIAVEIS "fim_variaveis"
%token INICIO "inicio"
%token FIM "fim"

%token SE "se"
%token ENTAO "entao"
%token SENAO "senao"
%token FIM_SE "fim_se"

%token PARA "para"
%token DE "de"
%token ATE "ate"
%token PASSO "passo"
%token FIM_PARA "fim_para"

%token ENQUANTO "enquanto"
%token FACA "faca"
%token FIM_ENQUANTO "fim_enquanto"

%token FUNCAO "funcao"
%token RETORNE "retorne"

%token DESCONHECIDO

%type <tp_expr_typecheck> expr termo fcall lvalue
%type <tp_expr> tp_matriz 
%type <tp_expr> tp_prim tp_prim_pl
%type <node> literal stm_block stm_list stm_lists stm_attr stm_ret stm_se stm_enquanto stm_para
%type <node> passo_exp passo_val
%type <lista_var> fparam fparams fvar_decl var_decl_list var_decl var_decl_id_list
%type <fargs_type> fargs

%left "ou"
%left "e"
%left '|'
%left '^'
%left '&'
%left "=" "<>"
%left "<" ">" "<=" ">="
%left '+' '-'
%left '*' '/' '%'
%%

algoritmo_goal: algoritmo_decl var_decl_block stm_block func_decls_list {
    tbl_funcoes* chamada = all_calls_accepted(hashmap_func);
    if (chamada != NULL) {
        fprintf(stderr, "Erro semantico na linha %d: função '%s' não foi declarada.\n", chamada->fcalls->linha_chamada, chamada->nome);
        exit(1);
    }
    verify_all_typechecks(tc_forest);
    run_ast(bloco_principal);
}
| algoritmo_decl stm_block func_decls_list {
    tbl_funcoes* chamada = all_calls_accepted(hashmap_func);
    if (chamada != NULL) {
        fprintf(stderr, "Erro semantico na linha %d: função '%s' não foi declarada.\n", chamada->fcalls->linha_chamada, chamada->nome);
        exit(1);
    }
    verify_all_typechecks(tc_forest);
    run_ast(bloco_principal);
}
| algoritmo_decl var_decl_block stm_block {
    tbl_funcoes* chamada = all_calls_accepted(hashmap_func);
    if (chamada != NULL) {
        fprintf(stderr, "Erro semantico na linha %d: função '%s' não foi declarada.\n", chamada->fcalls->linha_chamada, chamada->nome);
        exit(1);
    }
    verify_all_typechecks(tc_forest);
    run_ast(bloco_principal);
}
| algoritmo_decl stm_block {
    tbl_funcoes* chamada = all_calls_accepted(hashmap_func);
    if (chamada != NULL) {
        fprintf(stderr, "Erro semantico na linha %d: função '%s' não foi declarada.\n", chamada->fcalls->linha_chamada, chamada->nome);
        exit(1);
    }
    verify_all_typechecks(tc_forest);
    run_ast(bloco_principal);
} ;

func_decls_list: func_decls
| func_decls_list func_decls ;

algoritmo_decl: "algoritmo" T_IDENTIFICADOR ';' ;

var_decl_block: "variaveis" var_decl_list "fim_variaveis" {
    //Como essa sintaxe só se apresenta no bloco principal, adiciona
    //as múltiplas variáveis à tabela hash correspondente
    insert_multi_var($2, hashmap_var_bloco_principal);
};

var_decl_list: var_decl ';' {
    $$ = $1;
}
| var_decl_list var_decl ';' {
    $$ = merge_var_lists($1, $2);
};

var_decl: var_decl_id_list ':' tp_prim {
    $$ = $1;
    ajustar_tipo($1, $3);
}
| var_decl_id_list ':' tp_matriz {
    $$ = $1;
    ajustar_tipo($1, $3);
};

var_decl_id_list: T_IDENTIFICADOR {
    $$ = add_to_var_list(NULL, $1.label, $1.linha_decl, 0);
}
| var_decl_id_list ',' T_IDENTIFICADOR {
    $$ = add_to_var_list($1, $3.label, $3.linha_decl, 0);
};

tp_prim: "inteiro" { $$ = INTEIRO; }
| "logico" { $$ = LOGICO; }
| "real" { $$ = REAL; }
| "caractere" { $$ = CARACTERE; }
| "literal" { $$ = LITERAL; };

tp_prim_pl: "inteiros" { $$ = INTEIROS; }
| "logicos" { $$ = LOGICOS; }
| "reais" { $$ = REAIS; }
| "caracteres" { $$ = CARACTERES; }
| "literais" { $$ = LITERAIS; };

tp_matriz: "matriz" tp_matriz_size "de" tp_prim_pl {
    if ($4 == INTEIROS)
        $$ = MATRIZ_INTEIROS;
    else if ($4 == REAIS)
        $$ = MATRIZ_REAIS;
    else if ($4 == CARACTERES)
        $$ = MATRIZ_CARACTERES;
    else if ($4 == LOGICOS)
        $$ = MATRIZ_LOGICOS;
    else
        $$ = MATRIZ_LITERAIS;
};

tp_matriz_size: '[' T_INT_LIT ']'
| tp_matriz_size '[' T_INT_LIT ']' ;

stm_block: "inicio" "fim" {
    $$ = create_node(NULL, -1, BLOCO, 0);
    if (escopo == NULL)
        bloco_principal = $$;
}
| "inicio" stm_lists "fim" {
    $$ = $2;
    if (escopo == NULL)
        bloco_principal = $$;
};

stm_list: stm_attr
| fcall ';' { $$ = $1.node; }
| stm_ret
| stm_se
| stm_enquanto
| stm_para ;

stm_lists: stm_list {
    $$ = create_node(NULL, -1, BLOCO, 1);
    add_child($$, $1);
}
| stm_lists stm_list {
    $$ = create_node(NULL, -1, BLOCO, 2);
    add_child($$, $1);
    add_child($$, $2);
};

stm_ret: "retorne" ';' {
    $$ = create_node(NULL, -1, RETORNE, 0);
}
| "retorne" expr ';' {
    add_to_forest($2.expr, tc_forest);
    $$ = create_node(NULL, -1, RETORNE, 1);
    add_child($$, $2.node);
};

lvalue: T_IDENTIFICADOR {
    tbl_variaveis* elem_found;
    if (escopo == NULL)
        elem_found = lookup_var($1.label, hashmap_var_bloco_principal);
    else
        elem_found = lookup_var($1.label, get_fnc_hashmap_var(escopo));
    if (elem_found == NULL) {
        fprintf(stderr, "Erro semantico na linha %d: variável '%s' não foi declarada.\n", $1.linha_decl, $1.label);
        exit(1);
    }
    $$.funcao = NULL;
    $$.tipo = elem_found->tipo;
    $$.linha_chamada = $1.linha_decl;
    $$.node = create_node($1.label, -1, VARIAVEIS, 0);
}
| T_IDENTIFICADOR lvalue_pos {
    tbl_variaveis* elem_found;
    if (escopo == NULL)
        elem_found = lookup_var($1.label, hashmap_var_bloco_principal);
    else
        elem_found = lookup_var($1.label, get_fnc_hashmap_var(escopo));
    if (elem_found == NULL) {
        fprintf(stderr, "Erro semantico na linha %d: variável '%s' não foi declarada.\n", $1.linha_decl, $1.label);
        exit(1);
    }
    $$.funcao = NULL;
    $$.tipo = elem_found->tipo;
    $$.linha_chamada = $1.linha_decl;
    $$.node = create_node($1.label, -1, VARIAVEIS, 0);
};

lvalue_pos: '[' expr ']' { add_to_forest($2.expr, tc_forest); }
| lvalue_pos '[' expr ']' { add_to_forest($3.expr, tc_forest); };

stm_attr: lvalue ":=" expr ';' {
    set_expr_type($3.expr, expr_op_attr($1.tipo, $3.tipo, $3.linha_chamada));
    add_to_forest($3.expr, tc_forest);
    $$ = create_node(NULL, -1, OP_ATR, 2);
    add_child($$, $1.node);
    add_child($$, $3.node);
};

stm_se: "se" expr "entao" stm_lists "fim_se" {
    $$ = create_node(NULL, -1, SE, 2);
    add_child($$, $2.node);
    add_child($$, $4);
}
| "se" expr "entao" "fim_se" {
    $$ = create_node(NULL, -1, SE, 2);
    add_child($$, $2.node);
    add_child($$, create_node(NULL, -1, BLOCO, 0));
}
| "se" expr "entao" stm_lists "senao" stm_lists "fim_se" {
    $$ = create_node(NULL, -1, SE, 3);
    add_child($$, $2.node);
    add_child($$, $4);
    add_child($$, $6);
}
| "se" expr "entao" "senao" stm_lists "fim_se" {
    $$ = create_node(NULL, -1, SE, 3);
    add_child($$, $2.node);
    add_child($$, create_node(NULL, -1, BLOCO, 0));
    add_child($$, $5);
}
| "se" expr "entao" stm_lists "senao" "fim_se" {
    $$ = create_node(NULL, -1, SE, 3);
    add_child($$, $2.node);
    add_child($$, $4);
    add_child($$, create_node(NULL, -1, BLOCO, 0));
}
| "se" expr "entao" "senao" "fim_se" {
    $$ = create_node(NULL, -1, SE, 3);
    add_child($$, $2.node);
    add_child($$, create_node(NULL, -1, BLOCO, 0));
    add_child($$, create_node(NULL, -1, BLOCO, 0));
};

stm_enquanto: "enquanto" expr "faca" stm_lists "fim_enquanto" {
    $$ = create_node(NULL, -1, ENQUANTO, 2);
    add_child($$, $2.node);
    add_child($$, $4);
}
| "enquanto" expr "faca" "fim_enquanto" {
    $$ = create_node(NULL, -1, ENQUANTO, 2);
    add_child($$, $2.node);
    add_child($$, create_node(NULL, -1, BLOCO, 0));
};

stm_para: "para" lvalue "de" expr "ate" expr "faca" stm_lists "fim_para" {
    $$ = create_node(NULL, -1, PARA, 4);
    add_child($$, $2.node);
    add_child($$, $4.node);
    add_child($$, $6.node);
    add_child($$, $8);
}
| "para" lvalue "de" expr "ate" expr passo_exp "faca" stm_lists "fim_para" {
    $$ = create_node(NULL, -1, PARA, 5);
    add_child($$, $2.node);
    add_child($$, $4.node);
    add_child($$, $6.node);
    add_child($$, $7);
    add_child($$, $9);    
}
| "para" lvalue "de" expr "ate" expr "faca" "fim_para" {
    $$ = create_node(NULL, -1, PARA, 4);
    add_child($$, $2.node);
    add_child($$, $4.node);
    add_child($$, $6.node);
    add_child($$, create_node(NULL, -1, BLOCO, 0));
}
| "para" lvalue "de" expr "ate" expr passo_exp "faca" "fim_para" {
    $$ = create_node(NULL, -1, PARA, 5);
    add_child($$, $2.node);
    add_child($$, $4.node);
    add_child($$, $6.node);
    add_child($$, $7);
    add_child($$, create_node(NULL, -1, BLOCO, 0));    
};

passo_exp: "passo" passo_val { $$ = $2; } ;

passo_val: '+' T_INT_LIT {
    $$ = create_node(NULL, -1, OP_UPLUS, 1);
    add_child($$, $2);
}
| '-' T_INT_LIT {
    $$ = create_node(NULL, -1, OP_UMINUS, 1);
    add_child($$, $2);   
}
| T_INT_LIT ;

expr: expr "ou" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_log($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_LOG, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_LOG_OU, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr "e" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_log($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_LOG, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_LOG_E, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr '|' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_bin($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_BIN, $1.expr, $3.expr);
}
| expr '^' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_bin($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_BIN, $1.expr, $3.expr);
}
| expr '&' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_bin($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_BIN, $1.expr, $3.expr);
}
| expr "=" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_rel_eqineq($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_REL_EQL, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_REL_EQ, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr "<>" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_rel_eqineq($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_REL_INEQL, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_REL_INEQ, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr ">" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_rel_cmp($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_REL_CMP, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_REL_GT, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr ">=" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_rel_cmp($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_REL_CMP, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_REL_GTEQ, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr "<" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_rel_cmp($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_REL_CMP, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_REL_LT, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr "<=" expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_rel_cmp($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_REL_CMP, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, OP_REL_LTEQ, 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr '+' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_arit($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_ARIT, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, '+', 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr '-' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_arit($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_ARIT, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, '-', 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr '/' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_arit($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_ARIT, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, '/', 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr '*' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_arit($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_ARIT, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, '*', 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| expr '%' expr {
    $$.funcao = NULL;
    $$.linha_chamada = $1.linha_chamada;
    $$.tipo = expr_op_mod($1.tipo, $3.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_MOD, $1.expr, $3.expr);
    $$.node = create_node(NULL, -1, '%', 2);
    add_child($$.node, $1.node);
    add_child($$.node, $3.node);
}
| '+' termo {
    $$.funcao = NULL;
    $$.linha_chamada = $2.linha_chamada;
    $$.tipo = expr_op_unary($2.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_UNARY, $2.expr, NULL);
    $$.node = create_node(NULL, -1, OP_UPLUS, 1);
    add_child($$.node, $2.node);
}
| '-' termo {
    $$.funcao = NULL;
    $$.linha_chamada = $2.linha_chamada;
    $$.tipo = expr_op_unary($2.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_UNARY, $2.expr, NULL);
    $$.node = create_node(NULL, -1, OP_UMINUS, 1);
    add_child($$.node, $2.node);
}
| '~' termo {
    $$.funcao = NULL;
    $$.linha_chamada = $2.linha_chamada;
    $$.tipo = expr_op_unot($2.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_UNOT, $2.expr, NULL);
}
| "nao" termo {
    $$.funcao = NULL;
    $$.linha_chamada = $2.linha_chamada;
    $$.tipo = expr_op_not($2.tipo, $$.linha_chamada);
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, OP_NOT, $2.expr, NULL);
    $$.node = create_node(NULL, -1, OP_LOG_NAO, 1);
    add_child($$.node, $2.node);
}
| termo {
    $$ = $1;
    $$.expr = new_typecheck($$.funcao, $$.tipo, $$.linha_chamada, -1, $1.expr, NULL);
};

termo: fcall {
    $$ = $1;
    $$.expr = NULL;
}
| lvalue {
    $$ = $1;
    $$.expr = NULL;
}
| literal {
    $$.funcao = NULL;
    $$.tipo = assoc_type($1->type);
    $$.linha_chamada = line_num;
    $$.expr = NULL;
    $$.node = $1;
}
| '(' expr ')' {
    $$ = $2;
};

fcall: T_IDENTIFICADOR '(' ')' {
    tbl_funcoes* elem_found = lookup_fnc($1.label);
    if (elem_found == NULL || !elem_found->declarada) {
        $$.funcao = $1.label;
        $$.tipo = INDEFINIDO;
        $$.linha_chamada = $1.linha_decl;
        $$.node = create_node($$.funcao, -1, FUNCAO, 0);
        new_call($1.label, NULL, $1.linha_decl);
    }
    else if (elem_found->aridade != 0) {
        fprintf(stderr, "Erro semantico na linha %d: a funcao '%s' foi chamada com %d argumentos mas declarada com %d parâmetros.\n", $1.linha_decl, $1.label, 0, elem_found->aridade);
        exit(1);
    }
    else {
        $$.funcao = NULL;
        $$.tipo = elem_found->retorno;
        $$.linha_chamada = $1.linha_decl;
        $$.node = create_node($1.label, -1, FUNCAO, 0);
    }
}
| T_IDENTIFICADOR '(' fargs ')' {
    tbl_funcoes* elem_found = lookup_fnc($1.label);
    if (elem_found == NULL || !elem_found->declarada) {
        $$.funcao = $1.label;
        $$.tipo = INDEFINIDO;
        $$.linha_chamada = $1.linha_decl;
        $$.node = create_node($$.funcao, -1, FUNCAO, $3.size);
        add_children($$.node, $3.ast_forest);
        new_call($1.label, $3.expr_forest, $1.linha_decl);
    }
    else if (elem_found->aridade != $3.size && elem_found->aridade != -1) {
        fprintf(stderr, "Erro semantico na linha %d: a funcao '%s' foi chamada com %d argumentos mas declarada com %d parâmetros.\n", $1.linha_decl, $1.label, $3.size, elem_found->aridade);
        exit(1);
    }
    else {
        check_params($1.label, $3.expr_forest);
        $$.funcao = NULL;
        $$.tipo = elem_found->retorno;
        $$.linha_chamada = $1.linha_decl;
        $$.node = create_node($1.label, -1, FUNCAO, $3.size);
        add_children($$.node, $3.ast_forest);
    }
};

fargs: expr {
    $$.size = 1;
    $$.expr_forest = add_to_forest($1.expr, NULL);
    $$.ast_forest = add_to_ast_forest($1.node, NULL);
}
| fargs ',' expr {
    $$.size = $1.size + 1;
    $$.expr_forest = add_to_forest($3.expr, $1.expr_forest);
    $$.ast_forest = add_to_ast_forest($3.node, $1.ast_forest);
} ;

literal: T_STRING_LIT
| T_INT_LIT
| T_REAL_LIT
| T_CARAC_LIT
| T_KW_VERDADEIRO
| T_KW_FALSO;

func_decls: func_sig_var_decl stm_block {
    insert_block(escopo, $2);
}

func_sig_var_decl: func_sig fvar_decl {
    insert_multi_var($2, get_fnc_hashmap_var(escopo));
}
| func_sig;

func_sig: "funcao" T_IDENTIFICADOR '(' fparams ')' ':' tp_prim {
    muda_escopo($2.label, &escopo);
    tbl_funcoes* f = insert_fnc($2.label, $2.linha_decl, size($4), $7, 1, $4);
    accept_calls(f);
}
| "funcao" T_IDENTIFICADOR '(' ')' ':' tp_prim {
    muda_escopo($2.label, &escopo);
    tbl_funcoes* f = insert_fnc($2.label, $2.linha_decl, 0, $6, 1, NULL);
    accept_calls(f);
}
| "funcao" T_IDENTIFICADOR '(' fparams ')' {
    muda_escopo($2.label, &escopo);
    tbl_funcoes* f = insert_fnc($2.label, $2.linha_decl, size($4), VOID, 1, $4);
    accept_calls(f);
}
| "funcao" T_IDENTIFICADOR '(' ')' {
    muda_escopo($2.label, &escopo);
    tbl_funcoes* f = insert_fnc($2.label, $2.linha_decl, 0, VOID, 1, NULL);
    accept_calls(f);
};

fvar_decl: var_decl ';' {
    $$ = $1;
}
| fvar_decl var_decl ';' {
    $$ = merge_var_lists($1, $2);
};

fparams: fparam {
    $$ = $1;
}
| fparams ',' fparam {
    $$ = merge_var_lists($1, $3);
};

fparam: T_IDENTIFICADOR ':' tp_prim {
    $$ = add_to_var_list(NULL, $1.label, $1.linha_decl, $3);
}
| T_IDENTIFICADOR ':' tp_matriz {
    $$ = add_to_var_list(NULL, $1.label, $1.linha_decl, $3);
};


%%

unsigned assoc_type(int type) {
    switch(type) {
        case T_INT_LIT:
            return INTEIRO;
        case T_STRING_LIT:
            return LITERAL;
        case T_CARAC_LIT:
            return CARACTERE;
        case T_REAL_LIT:
            return REAL;
        default:
            return LOGICO;
    }
}

void yyerror(char const *s) {
	fprintf(stderr, "%s\n", s);
	exit(1);
}

int main () {
	int i = 0;
    tc_forest = NULL;
    hashmap_var_bloco_principal = malloc(HASH_SIZE*sizeof(struct str_hashmap_var));
    hashmap_func = malloc(HASH_SIZE*sizeof(struct str_hashmap_funcoes));
    for (i = 0; i < HASH_SIZE; i++) {
    	hashmap_var_bloco_principal[i].tbl_var = NULL;
    	hashmap_func[i].tbl_fnc = NULL;
    }
    pilha_valores = NULL;
    //Inserir leia() e imprima()
    insert_fnc("leia",0,0,INDEFINIDO,1,NULL);
    insert_fnc("imprima",0,-1,VOID,1,NULL);
    escopo = NULL;
    yyparse();
    return 0;
}
