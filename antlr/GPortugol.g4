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

prog : algoritmo;

algoritmo 
	: declaracao_algoritmo var_decl_block? stm_block func_decls*
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
	:	'logico'
	|	'literal'	
	|	'caractere'
	|	'real'
	|	'inteiro'
	;

tp_matriz 
	: 'matriz' ('[' INTEIRO ']')+ 'de' tp_prim_pl
	;

tp_prim_pl 
	:	'logicos'
	|	'literais'
	|	'caracteres'
	|	'reais'
	|	'inteiros'
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
	:	lvalue ':=' expr ';'
	;

stm_se
	:	'se' expr 'entao' stm_list ('senao' stm_list)? 'fim_se'
	;

stm_enquanto
	:	'enquanto' expr 'faca' stm_list 'fim_enquanto'
	;

stm_para
	:	'para' lvalue 'de' expr 'ate' expr passo? 'faca' stm_list 'fim_para'
	;

passo
	:	'passo' ('+'|'-')? INTEIRO
	;

expr
	:	('+'|'-'|'~'|'nao')? termo
	|	expr ('/'|'*'|'%') expr
	|	expr ('+'|'-') expr
	|	expr ('>'|'>='|'<'|'<=') expr
	|	expr ('='|'<>') expr
	|	expr '&' expr
	|	expr '^' expr
	|	expr '|' expr
	|	expr ('e'||'&&') expr
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
	:	'falso'
	|	'verdadeiro'
	|	CARACTERE
	|	REAL
	|	INTEIRO
	|	STRING
	;

func_decls
	:	stm_block
	|	fvar_decl
	|	'funcao' IDENTIFICADOR '(' fparams? ')' (':' tp_primitivo)?
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

LOGICO : 'verdadeiro' | 'falso'; 

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

INTEIRO : HEXA | OCTAL | BINARIO | ('-'|'+')? DECIMAL ; 

REAL : ('-'|'+')? DECIMAL '.' DECIMAL+ ; 

CARACTERE : '\''(~('\'' | '\\')|'\\'.)?'\'' ; 

STRING : '"' (~('"' | '\\' | '\n' | '\r')|'\\'.)* '"' ; 

IDENTIFICADOR : (LETRA | '_')(LETRA | DIGITO | '_')*; 

ATRIBUICAO : ':=' ; 

ESPECIAL : '('|')'|'['|']'|';'|','|':';
WS : [ \t\r\n]+ -> skip;

UNKNOWN : . {System.out.println(getText() + " -> DESCONHECIDO");};