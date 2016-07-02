/* Alunos:
		Gabriel Correa de Macena
		Marcus Vinicius Palassi Sales
*/

grammar GPortugol;

fragment DIGITO : [0-9];
fragment NAOZERO : [1-9];
fragment LETRA : [a-zA-Z];
fragment HEXA : '0'[xX](DIGITO | [a-fA-F])+;
fragment OCTAL : '0'[cC][0-7]+;
fragment BINARIO : '0'[bB][01]+;
fragment DECIMAL : DIGITO+ ;

algoritmo
	:	declaracao_algoritmo var_decl_block? stm_block func_decls+ EOF
	|	declaracao_algoritmo var_decl_block? stm_block EOF
	;

declaracao_algoritmo
	: 'algoritmo' IDENTIFICADOR ';'
	;

var_decl_block
	: 'variaveis' (var_decl ';')+ 'fim_variaveis'
	;

var_decl
	: IDENTIFICADOR (',' IDENTIFICADOR)* ':' (tp_primitivo | tp_matriz)
	;

tp_primitivo
	:	LOGICO
	|	LITERAL
	|	CARACTERE_WORD
	|	REAL_WORD
	|	INTEIRO_WORD
	;

tp_matriz
	: 'matriz' ('[' INTEIRO ']')+ 'de' tp_prim_pl
	;

tp_prim_pl
	:	LOGICOS
	|	LITERAIS
	|	CARACTERES_WORD
	|	REAIS_WORD
	|	INTEIROS_WORD
	;

stm_block
	:	'inicio' (stm_list)* 'fim'
	;

stm_list
	:	stm_para
	|	stm_enquanto
	|	stm_se
	|	stm_ret
	|	fcall ';'
	|	stm_attr
	;

stm_ret
	:	'retorne' expr? ';'
	;

lvalue
	:	IDENTIFICADOR ('[' expr ']')*
	;

stm_attr
	:	lvalue ATRIBUICAO expr ';'
	;


/*
	Para as estruturas de repetiçao, foi escolhido que a lista de comandos
	(stm_list) pode ser vazia.
*/
stm_se
	:	'se' expr 'entao' stm_list* ('senao' stm_list*)? 'fim_se'
	;

stm_enquanto
	:	'enquanto' expr 'faca' stm_list* 'fim_enquanto'
	;

stm_para
	:	'para' lvalue 'de' expr 'ate' expr passo? 'faca' stm_list* 'fim_para'
	;

passo
	:	'passo' (OP_ADD|OP_SUB)? INTEIRO
	;

expr
	:	(OP_ADD|OP_SUB|NAO_BINARIO|NAO_LOGICO)? termo
	|	expr (OP_DIV|OP_MUL|OP_MOD) expr 
	|	expr (OP_ADD|OP_SUB) expr 
	|	expr (OP_MORE|OP_MORE_EQUAL|OP_LESS|OP_LESS_EQUAL) expr
	|	expr (OP_EQUAL|OP_DIFF) expr
	|	expr E_BINARIO expr
	|	expr XOR_BINARIO expr 
	|	expr OU_BINARIO expr
	|	expr E_LOGICO expr 
	|	expr OU_LOGICO expr 
	;

termo
	:	'(' expr ')'
	|	literal
	|	lvalue
	|	fcall
	;

fcall
	:	IDENTIFICADOR '(' fargs? ')'
	;

fargs
	:	expr (',' expr)*
	;

literal
	:	T_KW_FALSO
	|	T_KW_VERDADEIRO
	|	CARACTERE
	|	REAL
	|	INTEIRO
	|	STRING
	;

func_decls
	:	'funcao' IDENTIFICADOR '(' fparams? ')' (':' tp_primitivo)? fvar_decl stm_block
	;

fvar_decl
	:	(var_decl ';')*
	;

fparams
	:	fparam (',' fparam)*
	;

fparam
	:	IDENTIFICADOR ':' (tp_primitivo | tp_matriz)
	;

COMENTARIO_LINHA : '//' .*? '\n' -> skip;
COMENTARIO_BLOCO : '/*' .*? '*/' -> skip;

T_KW_VERDADEIRO: 'verdadeiro';
T_KW_FALSO: 'falso';

OP_ADD: '+';
OP_SUB: '-';
OP_MUL: '*';
OP_DIV: '/';
OP_MOD: '%';
OP_LESS: '<';
OP_LESS_EQUAL: '<=';
OP_MORE: '>';
OP_MORE_EQUAL: '>=';
OP_EQUAL: '=';
OP_DIFF: '<>';
E_LOGICO: 'e';
OU_LOGICO: 'ou';
NAO_LOGICO: 'nao';
NAO_BINARIO: '~';
OU_BINARIO: '|';
E_BINARIO: '&';
XOR_BINARIO: '^';

LOGICO : 'logico';
LOGICOS : 'logicos';
LITERAL : 'literal';
LITERAIS: 'literais';
CARACTERE_WORD : 'caractere';
CARACTERES_WORD : 'caracteres';
REAL_WORD : 'real';
REAIS_WORD : 'reais';
INTEIRO_WORD : 'inteiro';
INTEIROS_WORD : 'inteiros';

INTEIRO : HEXA | OCTAL | BINARIO | DECIMAL ;

REAL : DECIMAL '.' DECIMAL+ ;

CARACTERE : '\''(~('\'' | '\\')|'\\'.)?'\'' ;

STRING : '"' (~('"' | '\\' | '\n' | '\r')|'\\'.)* '"' ;

IDENTIFICADOR : (LETRA | '_')(LETRA | DIGITO | '_')*;

ATRIBUICAO : ':=' ;

ESPECIAL : '('|')'|'['|']'|';'|','|':';
WS : [ \t\r\n]+ -> skip;
