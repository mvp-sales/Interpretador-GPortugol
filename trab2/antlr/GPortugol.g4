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

prog: algoritmo;

algoritmo
	:	declaracao_algoritmo var_decl_block? stm_block func_decls+ EOF
	|	declaracao_algoritmo var_decl_block? stm_block EOF
	;

declaracao_algoritmo 
	: ALGORITMO IDENTIFICADOR ';'
	;

var_decl_block 
	: VARIAVEIS (var_decl ';')+ FIM_VARIAVEIS
	;

var_decl 
	: IDENTIFICADOR (',' IDENTIFICADOR)* ':' (tp_primitivo | tp_matriz)
	;

tp_primitivo 
	:	LOGICO_WORD
	|	LITERAL_WORD	
	|	CARACTERE_WORD
	|	REAL_WORD
	|	INTEIRO_WORD
	;

tp_matriz 
	: MATRIZ ('[' INTEIRO ']')+ DE tp_prim_pl
	;

tp_prim_pl 
	:	LOGICOS_WORD
	|	LITERAIS_WORD
	|	CARACTERES_WORD
	|	REAIS_WORD
	|	INTEIROS_WORD
	;

stm_block
	:	INICIO (stm_list)* FIM
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
	:	RETORNE expr? ';'
	;

lvalue
	:	IDENTIFICADOR ('[' expr ']')*
	;

stm_attr
	:	lvalue ATRIBUICAO expr ';'
	;

stm_se
	:	SE expr ENTAO stm_list* (SENAO stm_list*)? FIM_SE
	;

stm_enquanto
	:	ENQUANTO expr FACA stm_list* FIM_ENQUANTO
	;

stm_para
	:	PARA lvalue DE expr ATE expr passo? FACA stm_list* FIM_PARA
	;

passo
	:	PASSO ('+'|'-')? INTEIRO
	;

expr
	:	(OP_ARITMETICO_PLUS|OP_ARITMETICO_MINUS|'~'|OP_LOGICO_NAO)? termo
	|	expr (OP_ARITMETICO_DIV|OP_ARITMETICO_MULT|OP_ARITMETICO_MOD) expr
	|	expr (OP_ARITMETICO_PLUS|OP_ARITMETICO_MINUS) expr
	|	expr (OP_RELACIONAL_BIGGER|OP_RELACIONAL_BIGGEREQUAL|OP_RELACIONAL_LESS|OP_RELACIONAL_LESSEQUAL) expr
	|	expr (OP_RELACIONAL_EQUAL|OP_RELACIONAL_DIFF) expr
	|	expr '&' expr
	|	expr '^' expr
	|	expr '|' expr
	|	expr ('e'|'&&') expr
	|	expr ('ou'|'||') expr
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
	:	LOGICO_FALSO
	|	LOGICO_VERDADEIRO
	|	CARACTERE
	|	REAL
	|	INTEIRO
	|	STRING
	;

func_decls
	:	FUNCAO IDENTIFICADOR '(' fparams? ')' (':' tp_primitivo)? fvar_decl stm_block
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

VARIAVEIS: 'variaveis';
FIM_VARIAVEIS: 'fim_variaveis';
ALGORITMO: 'algoritmo';
INTEIRO_WORD: 'inteiro';
INTEIROS_WORD: 'inteiros';
REAL_WORD: 'real';
REAIS_WORD: 'reais';
INICIO: 'inicio';
FIM: 'fim';
SE: 'se';
FIM_SE: 'fim_se';
SENAO: 'senao';
CARACTERE_WORD: 'caractere';
CARACTERES_WORD: 'caracteres';
LITERAL_WORD: 'literal';
LITERAIS_WORD: 'literais';
LOGICO_WORD: 'logico';
LOGICOS_WORD: 'logicos';
ENTAO: 'entao';
ENQUANTO: 'enquanto';
FIM_ENQUANTO: 'fim_enquanto';
FACA: 'faca';
PARA: 'para';
FIM_PARA: 'fim_para';
DE: 'de';
ATE: 'ate';
MATRIZ: 'matriz';
FUNCAO: 'funcao';
RETORNE: 'retorne';
PASSO: 'passo';

LOGICO_FALSO: 'falso';
LOGICO_VERDADEIRO: 'verdadeiro';

OP_LOGICO_E: 'e';
OP_LOGICO_OU: 'ou';
OP_LOGICO_NAO: 'nao';

OP_ARITMETICO_PLUS: '+';
OP_ARITMETICO_MINUS: '-';
OP_ARITMETICO_MULT: '*';
OP_ARITMETICO_DIV: '/';
OP_ARITMETICO_MOD: '%';
OP_ARITMETICO_ADD1: '++';
OP_ARITMETICO_MINUS1: '--';

OP_RELACIONAL_LESS: '<';
OP_RELACIONAL_LESSEQUAL: '<=';
OP_RELACIONAL_BIGGER: '>';
OP_RELACIONAL_BIGGEREQUAL: '>=';
OP_RELACIONAL_EQUAL: '=';
OP_RELACIONAL_DIFF: '<>';


COMENTARIO_LINHA : '//' .*? '\n' -> skip;
COMENTARIO_BLOCO : '/*' .*? '*/' -> skip;

/*LOGICO : 'verdadeiro' | 'falso'; 

OP_LOGICO : 'e'|'ou'|'nao'; 

OP_ARITMETICO : '+'| '-' |'*'|'/'|'%'|'++'|'--' ; 

OP_RELACIONAL : '<'|'<='|'>'|'>='|'='|'<>' ;

RESERVADA : 
		'fim_variaveis' | 'algoritmo' | 'variaveis' | 'inteiro' 's'? 
		| 'rea'('l'|'is')|'caractere' 's'? | 'litera'('l'|'is') | 'logico' 's'? 
		| 'inicio' | 'fim' | LOGICO | OP_LOGICO | 'se' | 'senao' | 'entao' 
		| 'fim_'('se'|'enquanto'|'para') | 'enquanto' | 'faca' |'para' | 'de' 
		| 'ate' | 'matriz' | 'funcao' | 'retorne' | 'passo'
		;
*/
INTEIRO : HEXA | OCTAL | BINARIO | DECIMAL ; 

REAL : DECIMAL '.' DECIMAL+ ; 

CARACTERE : '\''(~('\'' | '\\')|'\\'.)?'\'' ; 

STRING : '"' (~('"' | '\\' | '\n' | '\r')|'\\'.)* '"' ; 

IDENTIFICADOR : (LETRA | '_')(LETRA | DIGITO | '_')*; 

ATRIBUICAO : ':='; 

ESPECIAL : '('|')'|'['|']'|';'|','|':';
WS : [ \t\r\n]+ -> skip;

UNKNOWN : . ;