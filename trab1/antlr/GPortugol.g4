/* Alunos:
		Gabriel Correa de Macena
		Marcus Vinicius Palassi Sales
*/

lexer grammar GPortugol;

fragment DIGITO : [0-9];
fragment NAOZERO : [1-9];
fragment LETRA : [a-zA-Z];
fragment HEXA : '0'[xX](DIGITO | [a-fA-F])+; 
fragment OCTAL : '0'[cC][0-7]+;
fragment BINARIO : '0'[bB][01]+;
fragment DECIMAL : DIGITO+ ;

/* No trabalho foi feita a escolha de representar inteiros com sinal, 
 portanto, expressoes como por exemplo, "z-1", sao "tokenizados" como 
 z como identificador e -1 como inteiro (caso haja espaço entre o numero e o sinal, 
 o - eh tokenizado como operador e o 1 como inteiro.
 Foi tentado o uso de semantic predicates, lexer modes para ter um lexer sensivel ao 
 contexto, mas nao deu certo. */

COMENTARIO_LINHA : '//' .*? '\n' -> skip;
COMENTARIO_BLOCO : '/*' .*? '*/' -> skip;

LOGICO : ('verdadeiro' | 'falso') {System.out.println(getText() + " -> LOGICO");}; 

OP_LOGICO : ('e'|'ou'|'nao') {System.out.println(getText() + " -> OPERADOR_LOGICO");}; 

OP_ARITMETICO : ('+'| '-' |'*'|'/'|'%'|'++'|'--') {System.out.println(getText() + " -> OPERADOR_ARITMETICO");}; 

OP_RELACIONAL : ('<'|'<='|'>'|'>='|'='|'<>') {System.out.println(getText() + " -> OPERADOR_RELACIONAL");};

RESERVADA : (
				'fim_variaveis' | 'algoritmo' | 'variaveis' | 'inteiro' 's'? 
				| 'rea'('l'|'is')|'caractere' 's'? | 'litera'('l'|'is') | 'logico' 's'? 
				| 'inicio' | 'fim' | LOGICO | OP_LOGICO | 'se' | 'senao' | 'entao' 
				| 'fim_'('se'|'enquanto'|'para') | 'enquanto' | 'faca' |'para' | 'de' 
				| 'ate' | 'matriz' | 'funcao' | 'retorne' | 'passo'
			) {System.out.println(getText() + " -> PALAVRA_RESERVADA");};

INTEIRO : (HEXA | OCTAL | BINARIO | ('-'|'+')? DECIMAL) {System.out.println(getText() + " -> INTEIRO");}; 

REAL : (('-'|'+')? DECIMAL '.' DECIMAL+) {System.out.println(getText() + " -> REAL");}; 

CARACTERE : ('\''(~('\'' | '\\')|'\\'.)?'\'') {System.out.println(getText() + " -> CARACTERE");}; 

STRING : ('"' (~('"' | '\\' | '\n' | '\r')|'\\'.)* '"') {System.out.println(getText() + " -> LITERAL");}; 

IDENTIFICADOR : ((LETRA | '_')(LETRA | DIGITO | '_')*) {System.out.println(getText() + " -> IDENTIFICADOR");}; 

ATRIBUICAO : ':=' {System.out.println(getText() + " -> ATRIBUICAO");}; 

ESPECIAL : ('('|')'|'['|']'|';'|','|':') {System.out.println(getText() + " -> SIMBOLO_ESPECIAL");};

WS : [ \t\r\n]+ -> skip;

UNKNOWN : . {System.out.println(getText() + " -> DESCONHECIDO");};