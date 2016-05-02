%{
#include<stdio.h>
#include<math.h>
#include<stdlib.h>
int yylex(void);
void yyerror(char const *s);
int node = 1;
%}

%union {
	int t_node;
	struct tipo_literal {
		int node;
		char* value;
	} t_value_string;
	struct tipo_numero {
		int node;
		double value;
	}  t_value_num;
	struct tipo_carac {
		int node;
		char value;
	}  t_value_carac;
	struct tipo_bool {
		int node;
		char* value;
	}  t_value_bool;
	struct label_struct {
		int node;
		char* label;
	}  t_label_struct;
};

%error-verbose
%token <t_value_string> T_STRING_LIT
%token <t_value_carac> T_CARAC_LIT
%token <t_value_num> T_INT_LIT
%token <t_value_num> T_REAL_LIT
%token <t_value_bool> T_KW_VERDADEIRO
%token <t_value_bool> T_KW_FALSO
%token <t_label_struct> T_IDENTIFICADOR
%token <t_label_struct> TP_PRIM
%token <t_label_struct> TP_PRIM_PL
%token <t_node> OP_REL_EQ "="
%token <t_node> OP_REL_INEQ "<>" 
%token <t_node> OP_REL_GT ">"
%token <t_node> OP_REL_GTEQ ">="
%token <t_node> OP_REL_LT "<"
%token <t_node> OP_REL_LTEQ "<="
%token <t_node> OP_ATR ":="
%token <t_node> OP_LOG_E "e"
%token <t_node> OP_LOG_OU "ou"
%token <t_node> OP_LOG_NAO "nao"
%token <t_node> ALGORITMO "algoritmo"
%token <t_node> VARIAVEIS "variaveis"
%token <t_node> FIM_VARIAVEIS "fim_variaveis"
%token <t_node> MATRIZ "matriz"
%token <t_node> INICIO "inicio"
%token <t_node> FIM "fim"
%token <t_node> SE "se"
%token <t_node> ENTAO "entao"
%token <t_node> SENAO "senao"
%token <t_node> FIM_SE "fim_se"
%token <t_node> PARA "para"
%token <t_node> DE "de"
%token <t_node> ATE "ate"
%token <t_node> PASSO "passo"
%token <t_node> FACA "faca"
%token <t_node> FIM_PARA "fim_para"
%token <t_node> ENQUANTO "enquanto"
%token <t_node> FIM_ENQUANTO "fim_enquanto"
%token <t_node> RETORNE "retorne"
%token <t_node> FUNCAO "funcao"
%token DESCONHECIDO
%type <t_node> '[' ']' '(' ')' ';' ':' ','
%type <t_node> '+' '-' '*' '/' '%'
%type <t_node> '|' '^' '&' '~'
%type <t_node> algoritmo_goal func_decls_list algoritmo_decl var_decl_block var_decls var_decl var_decl_id_list
%type <t_node> tp_matriz tp_matriz_size stm_block stm_list stm_lists stm_ret lvalue lvalue_pos
%type <t_node> stm_attr stm_se stm_enquanto stm_para passo_exp passo_val expr termo fcall fargs literal
%type <t_node> func_decls fvar_decl fparams fparam
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

/* Construção da Parse Tree
*  A variável global node é utilizada para controlar qual é o número atual do nó da árvore
*  a ser criado.
*  1. Cada vez que se obtém uma redução através de uma regra, cria-se um novo
*  nó, cujo label tem o mesmo nome que a cabeça da regra e cujo valor $$ é igual a node
*  (salvo no caso de algoritmo_decl, que começa com valor 0);
*  2. Uma vez criado o nó da cabeça, é preciso indicar quais são os nós filhos
*  dele - ou seja, olha-se para cada elemento no corpo da regra. Para tal, segue-se 
*  as seguintes regras:
*       a. Se for um não-terminal, o nó já foi criado previamente quando houve redução
*       por uma das regras em que o não-terminal aparece na cabeça e o número desse nó
*       estará armazenado na variável $n correspondente à sua posição. Assim, basta
*       indicar que esse nó é filho do nó da cabeça.
*       b. Se for um terminal, é preciso criar um novo nó com label igual ao nome/valor
*       do terminal e só então associar esse nó como filho do nó da cabeça. O número do 
*       nó estará preservado na variável $n correspondente à posição do terminal.
*/

algoritmo_goal: algoritmo_decl var_decl_block stm_block func_decls_list { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"algoritmo_goal\"];\n", $$); 
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("}\n");
}
| algoritmo_decl stm_block func_decls_list { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"algoritmo_goal\"];\n", $$); 
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
    printf("}\n");
}
| algoritmo_decl var_decl_block stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"algoritmo_goal\"];\n", $$); 
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
    printf("}\n");
}
| algoritmo_decl stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"algoritmo_goal\"];\n", $$); 
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("}\n");
};
func_decls_list: func_decls { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls_list\"];\n", $$); 
    printf("node%d -> node%d;\n", $$, $1);
}
| func_decls_list func_decls { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1); 
    printf("node%d -> node%d;\n", $$, $2);
};
algoritmo_decl: "algoritmo" T_IDENTIFICADOR ';' {
    $$ = 0; 
    printf("digraph {\ngraph [ordering=\"out\"];\n"); 
    printf("node0[label=\"algoritmo_decl\"];\n"); 
    printf("node%d[label=\"algoritmo\"];\n", $1);
    printf("node0 -> node%d;\n", $1); 
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label); 
    printf("node0 -> node%d;\n", $2.node);
    printf("node%d[label=\";\"];\n", $3);
    printf("node0 -> node%d;\n", $3);
};
var_decl_block: "variaveis" var_decls "fim_variaveis" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decl_block\"];\n", $$); 
    printf("node%d[label=\"variaveis\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1); 
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"fim_variaveis\"];\n", $3);
    printf("node%d -> node%d;\n", $$, $3);
};
var_decls: var_decl ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decls\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\";\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
}
| var_decls var_decl ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decls\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\";\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
};
var_decl: var_decl_id_list ':' TP_PRIM { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decl\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\":\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"%s\"];\n", $3.node, $3.label); 
    printf("node%d -> node%d;\n", $$, $3.node);
}
| var_decl_id_list ':' tp_matriz { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decl\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\":\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
};
var_decl_id_list: T_IDENTIFICADOR { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decl_id_list\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label); 
    printf("node%d -> node%d;\n", $$, $1.node);
}
| var_decl_id_list ',' T_IDENTIFICADOR { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"var_decl_id_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\",\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"%s\"];\n", $3.node, $3.label); 
    printf("node%d -> node%d;\n", $$, $3.node);
};
tp_matriz: "matriz" tp_matriz_size "de" TP_PRIM_PL { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"tp_matriz\"];\n", $$);
    printf("node%d[label=\"matriz\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"de\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\"%s\"];\n", $4.node, $4.label); 
    printf("node%d -> node%d;\n", $$, $4.node);
};
tp_matriz_size: '[' T_INT_LIT ']' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"tp_matriz_size\"];\n", $$);
    printf("node%d[label=\"[\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%d\"];\n", $2.node, (int) $2.value);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"]\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
}
| tp_matriz_size '[' T_INT_LIT ']' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"tp_matriz_size\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);    
    printf("node%d[label=\"[\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"%d\"];\n", $3.node, (int) $3.value);
    printf("node%d -> node%d;\n", $$, $3.node);
    printf("node%d[label=\"]\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
};
stm_block: "inicio" "fim" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_block\"];\n", $$);
    printf("node%d[label=\"inicio\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"fim\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
}
| "inicio" stm_lists "fim" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_block\"];\n", $$);
    printf("node%d[label=\"inicio\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"fim\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
};
stm_list: stm_attr { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| fcall ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\";\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
}
| stm_ret { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| stm_se { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| stm_enquanto { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| stm_para { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_list\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
};
stm_lists: stm_list { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_lists\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| stm_lists stm_list { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_lists\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
};
stm_ret: "retorne" ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_ret\"];\n", $$);
    printf("node%d[label=\"retorne\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\";\"];\n", $2); 
    printf("node%d -> node%d;\n", $$, $2);
}
| "retorne" expr ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_block\"];\n", $$);
    printf("node%d[label=\"inicio\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"fim\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
};
lvalue: T_IDENTIFICADOR { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"lvalue\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label); 
    printf("node%d -> node%d;\n", $$, $1.node);
}
| T_IDENTIFICADOR lvalue_pos { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"lvalue\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label); 
    printf("node%d -> node%d;\n", $$, $1.node);
    printf("node%d -> node%d;\n", $$, $2);
}; 
lvalue_pos: '[' expr ']' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"lvalue_pos\"];\n", $$);
    printf("node%d[label=\"[\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"]\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
}
| lvalue_pos '[' expr ']' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"lvalue_pos\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"[\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\"]\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
};
stm_attr: lvalue ":=" expr ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_attr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\":=\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\";\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
};
stm_se: "se" expr "entao" stm_lists "fim_se" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_se\"];\n", $$);
    printf("node%d[label=\"se\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"entao\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"fim_se\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
}
| "se" expr "entao" "fim_se" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_se\"];\n", $$);
    printf("node%d[label=\"se\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"entao\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\"fim_se\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
}
| "se" expr "entao" stm_lists "senao" stm_lists "fim_se" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_se\"];\n", $$);
    printf("node%d[label=\"se\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"entao\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"senao\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d[label=\"fim_se\"];\n", $7); 
    printf("node%d -> node%d;\n", $$, $7);
}
| "se" expr "entao" "senao" stm_lists "fim_se" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_se\"];\n", $$);
    printf("node%d[label=\"se\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"entao\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\"senao\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d[label=\"fim_se\"];\n", $6); 
    printf("node%d -> node%d;\n", $$, $6);
}
| "se" expr "entao" stm_lists "senao" "fim_se" {
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_se\"];\n", $$);
    printf("node%d[label=\"se\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"entao\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"senao\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d[label=\"fim_se\"];\n", $6); 
    printf("node%d -> node%d;\n", $$, $6);
}
| "se" expr "entao" "senao" "fim_se" {
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_se\"];\n", $$);
    printf("node%d[label=\"se\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"entao\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\"senao\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"fim_se\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
};
stm_enquanto: "enquanto" expr "faca" stm_lists "fim_enquanto" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_enquanto\"];\n", $$);
    printf("node%d[label=\"enquanto\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"faca\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"fim_enquanto\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
}
| "enquanto" expr "faca" "fim_enquanto" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_enquanto\"];\n", $$);
    printf("node%d[label=\"enquanto\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"faca\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\"fim_enquanto\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
};
stm_para: "para" lvalue "de" expr "ate" expr "faca" stm_lists "fim_para" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_para\"];\n", $$);
    printf("node%d[label=\"para\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"de\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"ate\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d[label=\"faca\"];\n", $7); 
    printf("node%d -> node%d;\n", $$, $7);
    printf("node%d -> node%d;\n", $$, $8);
    printf("node%d[label=\"fim_para\"];\n", $9); 
    printf("node%d -> node%d;\n", $$, $9);
}
| "para" lvalue "de" expr "ate" expr passo_exp "faca" stm_lists "fim_para" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_para\"];\n", $$);
    printf("node%d[label=\"para\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"de\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"ate\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d -> node%d;\n", $$, $7);
    printf("node%d[label=\"faca\"];\n", $8); 
    printf("node%d -> node%d;\n", $$, $8);
    printf("node%d -> node%d;\n", $$, $9);
    printf("node%d[label=\"fim_para\"];\n", $10); 
    printf("node%d -> node%d;\n", $$, $10);
}
| "para" lvalue "de" expr "ate" expr "faca" "fim_para" { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_para\"];\n", $$);
    printf("node%d[label=\"para\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"de\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"ate\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d[label=\"faca\"];\n", $7); 
    printf("node%d -> node%d;\n", $$, $7);
    printf("node%d[label=\"fim_para\"];\n", $8); 
    printf("node%d -> node%d;\n", $$, $8);
}
| "para" lvalue "de" expr "ate" expr passo_exp "faca" "fim_para"  { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"stm_para\"];\n", $$);
    printf("node%d[label=\"para\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"de\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\"ate\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d -> node%d;\n", $$, $7);
    printf("node%d[label=\"faca\"];\n", $8); 
    printf("node%d -> node%d;\n", $$, $8);
    printf("node%d[label=\"fim_para\"];\n", $9); 
    printf("node%d -> node%d;\n", $$, $9);
};
passo_exp: "passo" passo_val { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"passo_exp\"];\n", $$);
    printf("node%d[label=\"passo\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
};
passo_val: '+' T_INT_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"passo_val\"];\n", $$);
    printf("node%d[label=\"+\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%d\"];\n", $2.node, (int) $2.value);
    printf("node%d -> node%d;\n", $$, $2.node);
}
| '-' T_INT_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"passo_val\"];\n", $$);
    printf("node%d[label=\"-\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%d\"];\n", $2.node, (int) $2.value);
    printf("node%d -> node%d;\n", $$, $2.node);
}
| T_INT_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"passo_val\"];\n", $$);
    printf("node%d[label=\"%d\"];\n", $1.node, (int) $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
};
expr: expr "ou" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"ou\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr "e" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"e\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '|' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"|\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '^' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"^\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '&' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"&\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr "=" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"=\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr "<>" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"<>\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr ">" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\">\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr ">=" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\">=\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr "<" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"<\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr "<=" expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"<=\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '+' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"+\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '-' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"-\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '/' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"/\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '*' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"*\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| expr '%' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%c\"];\n", $2, '%');
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
| '+' expr %prec UNARY { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d[label=\"+\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
}
| '-' expr %prec UNARY { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d[label=\"-\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
}
| '~' expr %prec UNARY { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d[label=\"~\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
}
| "nao" expr %prec UNARY { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d[label=\"nao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
}
| termo { 
    node++; $$ = node; node++;
    printf("node%d[label=\"expr\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
};
termo: fcall { 
    node++; $$ = node; node++;
    printf("node%d[label=\"termo\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| lvalue { 
    node++; $$ = node; node++;
    printf("node%d[label=\"termo\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| literal { 
    node++; $$ = node; node++;
    printf("node%d[label=\"termo\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| '(' expr ')' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"termo\"];\n", $$);
    printf("node%d[label=\"(\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\")\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
};
fcall: T_IDENTIFICADOR '(' ')' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fcall\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label);
    printf("node%d -> node%d;\n", $$, $1.node);
    printf("node%d[label=\"(\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\")\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
}
| T_IDENTIFICADOR '(' fargs ')' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fcall\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label);
    printf("node%d -> node%d;\n", $$, $1.node);
    printf("node%d[label=\"(\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\")\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
};
fargs: expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"fargs\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| fargs ',' expr { 
    node++; $$ = node; node++;
    printf("node%d[label=\"fargs\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\",\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
};
literal: T_STRING_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"literal\"];\n", $$);
    printf("node%d[label=%s];\n", $1.node, $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
}
| T_INT_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"literal\"];\n", $$);
    printf("node%d[label=\"%d\"];\n", $1.node, (int) $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
}
| T_REAL_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"literal\"];\n", $$);
    printf("node%d[label=\"%f\"];\n", $1.node, $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
}
| T_CARAC_LIT { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"literal\"];\n", $$);
    printf("node%d[label=\"%c\"];\n", $1.node, $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
}
| T_KW_VERDADEIRO { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"literal\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
}
| T_KW_FALSO { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"literal\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.value);
    printf("node%d -> node%d;\n", $$, $1.node);
}
;
func_decls: "funcao" T_IDENTIFICADOR '(' ')'
fvar_decl
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\")\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
}
| "funcao" T_IDENTIFICADOR '(' fparams ')'
fvar_decl
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\")\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d -> node%d;\n", $$, $7);
} 
|"funcao" T_IDENTIFICADOR '(' ')' ':' TP_PRIM
fvar_decl
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\")\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\":\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d[label=\"%s\"];\n", $6.node, $6.label);
    printf("node%d -> node%d;\n", $$, $6.node);
    printf("node%d -> node%d;\n", $$, $7);
    printf("node%d -> node%d;\n", $$, $8);
}
| "funcao" T_IDENTIFICADOR '(' fparams ')' ':' TP_PRIM
fvar_decl
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\")\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d[label=\":\"];\n", $6); 
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d[label=\"%s\"];\n", $7.node, $7.label);
    printf("node%d -> node%d;\n", $$, $7.node);
    printf("node%d -> node%d;\n", $$, $8);
    printf("node%d -> node%d;\n", $$, $9);
}
| "funcao" T_IDENTIFICADOR '(' ')'
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\")\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d -> node%d;\n", $$, $5);
}
| "funcao" T_IDENTIFICADOR '(' fparams ')'
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\")\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d -> node%d;\n", $$, $6);
}
|"funcao" T_IDENTIFICADOR '(' ')' ':' TP_PRIM
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d[label=\")\"];\n", $4); 
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\":\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d[label=\"%s\"];\n", $6.node, $6.label);
    printf("node%d -> node%d;\n", $$, $6.node);
    printf("node%d -> node%d;\n", $$, $7);
}
| "funcao" T_IDENTIFICADOR '(' fparams ')' ':' TP_PRIM
stm_block { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"func_decls\"];\n", $$);
    printf("node%d[label=\"funcao\"];\n", $1);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\"%s\"];\n", $2.node, $2.label);
    printf("node%d -> node%d;\n", $$, $2.node);
    printf("node%d[label=\"(\"];\n", $3); 
    printf("node%d -> node%d;\n", $$, $3);
    printf("node%d -> node%d;\n", $$, $4);
    printf("node%d[label=\")\"];\n", $5); 
    printf("node%d -> node%d;\n", $$, $5);
    printf("node%d[label=\":\"];\n", $6); 
    printf("node%d -> node%d;\n", $$, $6);
    printf("node%d[label=\"%s\"];\n", $7.node, $7.label);
    printf("node%d -> node%d;\n", $$, $7.node);
    printf("node%d -> node%d;\n", $$, $8);
};
fvar_decl: var_decl ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fvar_decl\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\";\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
}
| fvar_decl var_decl ';' { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fvar_decl\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\";\"];\n", $3);
    printf("node%d -> node%d;\n", $$, $3); 
};
fparams: fparam { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fparams\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
}
| fparams ',' fparam { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fparams\"];\n", $$);
    printf("node%d -> node%d;\n", $$, $1);
    printf("node%d[label=\",\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
;
fparam: T_IDENTIFICADOR ':' TP_PRIM { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fparam\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label);
    printf("node%d -> node%d;\n", $$, $1.node);
    printf("node%d[label=\":\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d[label=\"%s\"];\n", $3.node, $3.label);
    printf("node%d -> node%d;\n", $$, $3.node);
}
| T_IDENTIFICADOR ':' tp_matriz { 
    node++; $$ = node; node++;    
    printf("node%d[label=\"fparam\"];\n", $$);
    printf("node%d[label=\"%s\"];\n", $1.node, $1.label);
    printf("node%d -> node%d;\n", $$, $1.node);
    printf("node%d[label=\":\"];\n", $2);
    printf("node%d -> node%d;\n", $$, $2);
    printf("node%d -> node%d;\n", $$, $3);
}
;


%%
