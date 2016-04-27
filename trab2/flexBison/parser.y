%{
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
int yylex(void);
void yyerror(char const *s);
/*struct pilha {
   char* label;
   struct pilha* next;    
};
#define PILHA struct pilha*
PILHA create_pilha() {
    return (PILHA) malloc(sizeof(struct pilha));
}
void destroy_pilha(PILHA p) {
    free(p);
}*/
%}

/*%define api.value.type {double}*/ // Tipo da variavel yylval
%token T_STRING_LIT
%token T_CARAC_LIT
%token T_INT_LIT
%token T_REAL_LIT
%token T_KW_VERDADEIRO
%token T_KW_FALSO
%token T_IDENTIFICADOR
%token DESCONHECIDO
%token TP_PRIM
%token TP_PRIM_PL
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
%token VARIAVEIS "variaveis"
%token FIM_VARIAVEIS "fim_variaveis"
%token MATRIZ "matriz"
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
%token FACA "faca"
%token FIM_PARA "fim_para"
%token ENQUANTO "enquanto"
%token FIM_ENQUANTO "fim_enquanto"
%token RETORNE "retorne"
%token FUNCAO "funcao"
%left "ou"
%left "e"
%left '|'
%left '^'
%left '&'
%left "=" "<>"
%left "<" ">" "<=" ">="
%left '+' '-'
%left '*' '/' '%'
%precedence UNARY
%%
algoritmo_goal: algoritmo_decl var_decl_block stm_block func_decls_list
| algoritmo_decl stm_block func_decls_list
| algoritmo_decl var_decl_block stm_block
| algoritmo_decl stm_block;
func_decls_list: func_decls
| func_decls_list func_decls;
algoritmo_decl: "algoritmo" T_IDENTIFICADOR ';' ;
var_decl_block: "variaveis" var_decl_block_list "fim_variaveis";
var_decl_block_list: var_decl ';'
| var_decl_block_list var_decl ';' ;
var_decl: var_decl_id_list ':' TP_PRIM 
| var_decl_id_list ':' tp_matriz;
var_decl_id_list: T_IDENTIFICADOR
| var_decl_id_list ',' T_IDENTIFICADOR;
/*tp_primitivo: "inteiro" 
| "real" 
| "caractere" 
| "literal" 
| "logico";*/
tp_matriz: "matriz" tp_matriz_size "de" TP_PRIM_PL ;
tp_matriz_size: '[' T_INT_LIT ']'
| tp_matriz_size '[' T_INT_LIT ']';
/*tp_prim_pl: "inteiros" 
| "reais" 
| "caracteres" 
| "literais" 
| "logicos";*/
stm_block: "inicio" "fim" 
| "inicio" stm_lists "fim" ;
stm_list: stm_attr 
| fcall ';' 
| stm_ret 
| stm_se 
| stm_enquanto
| stm_para;
stm_lists: stm_list
| stm_lists stm_list;
stm_ret: "retorne" ';' 
| "retorne" expr ';';
lvalue: T_IDENTIFICADOR
| T_IDENTIFICADOR lvalue_pos; 
lvalue_pos: '[' expr ']'
| lvalue_pos '[' expr ']';
stm_attr: lvalue ":=" expr ';' ;
stm_se: "se" expr "entao" stm_lists "fim_se" 
| "se" expr "entao" stm_lists "senao" stm_lists "fim_se" ;
stm_enquanto: "enquanto" expr "faca" stm_lists "fim_enquanto" ;
stm_para: "para" lvalue "de" expr "ate" expr "faca" stm_lists "fim_para"
| "para" lvalue "de" expr "ate" expr passo "faca" stm_lists "fim_para";
passo: "passo" passo_val;
passo_val: '+' T_INT_LIT
| '-' T_INT_LIT
| T_INT_LIT;
expr: expr "ou" expr
| expr "e" expr
| expr '|' expr
| expr '^' expr
| expr '&' expr
| expr "=" expr 
| expr "<>" expr
| expr ">" expr 
| expr ">=" expr 
| expr "<" expr 
| expr "<=" expr
| expr '+' expr
| expr '-' expr
| expr '/' expr 
| expr '*' expr 
| expr '%' expr
| '+' expr %prec UNARY
| '-' expr %prec UNARY
| '~' expr %prec UNARY
| "nao" expr %prec UNARY
| termo;
termo: fcall
| lvalue
| literal
| '(' expr ')' ;
fcall: T_IDENTIFICADOR '(' ')' 
| T_IDENTIFICADOR '(' fargs ')';
fargs: expr
| fargs ',' expr ;
literal: T_STRING_LIT
| T_INT_LIT
| T_REAL_LIT
| T_CARAC_LIT
| T_KW_VERDADEIRO
| T_KW_FALSO
;
func_decls: "funcao" T_IDENTIFICADOR '(' ')'
fvar_decl
stm_block 
| "funcao" T_IDENTIFICADOR '(' fparams ')'
fvar_decl
stm_block 
|"funcao" T_IDENTIFICADOR '(' ')' ':' TP_PRIM
fvar_decl
stm_block 
| "funcao" T_IDENTIFICADOR '(' fparams ')' ':' TP_PRIM
fvar_decl
stm_block
| "funcao" T_IDENTIFICADOR '(' ')'
stm_block 
| "funcao" T_IDENTIFICADOR '(' fparams ')'
stm_block 
|"funcao" T_IDENTIFICADOR '(' ')' ':' TP_PRIM
stm_block 
| "funcao" T_IDENTIFICADOR '(' fparams ')' ':' TP_PRIM
stm_block;
fvar_decl: var_decl ';'
| fvar_decl var_decl ';' ;
fparams: fparam
| fparams ',' fparam
;
fparam: T_IDENTIFICADOR ':' TP_PRIM 
| T_IDENTIFICADOR ':' tp_matriz
;



/*
lines: %empty
| lines expr '\n'       { printf(">> %g\n", $2); } ;
lista_id: IDENTIFICADOR
| IDENTIFICADOR ',' id
expr: NUMERO
| IDENTIFICADOR
| IDENTIFICADOR ":=" expr ';'  { $$ = $3; }
| expr '+' expr         { $$ = $1 + $3; }
| expr '-' expr         { $$ = $1 - $3; }
| expr '*' expr         { $$ = $1 * $3; }
| expr '/' expr         { $$ = $1 / $3; } 
| expr '^' expr         { $$ = pow($1, $3); }
| '-' expr  %prec UNARY  { $$ = -$2; }
| '+' expr  %prec UNARY  { $$ = -$2; }
| '(' expr ')'          { $$ = $2; };
lista_expr: %empty
| expr ';'
| expr ';' lista_expr
lista_attr: %empty
| lista_attr attr;
condicao: expr RELACIONAL expr ;
enquanto: "enquanto" condicao "faca" lista_expr "fim_enquanto" ;
para: "para" IDENTIFICADOR "de" expr "ate" expr "faca" lista_expr "fim_para" 
| "para" IDENTIFICADOR "de" expr "ate" expr "passo" expr "faca" lista_expr "fim_para";*/
%%

/*void yyerror(const char *s) {
	printf("EEK, parse error on line %d! Message: %s\n", line_num, s);
	// might as well halt now:
	exit(-1);
}*/
