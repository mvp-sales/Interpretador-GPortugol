%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%{
#include <stdio.h>
#include "parser.h"
#include "ast.h"
char* string_frag(char* string);
extern int line_num;
%}

digito  [0-9]
letra [a-zA-Z]
comentario_linha "//"[^\n]*("\n")?
comentario_bloco "/*"(("*"[^'/'])|[^"*"])*"*/"
hexa 0[Xx]({digito}|[A-Fa-f])+
octal 0[Cc][0-7]+
binario 0[Bb][01]+
decimal {digito}+
tp_prim "inteiro"|"real"|"caractere"|"literal"|"logico"
tp_prim_plural "inteiros"|"reais"|"caracteres"|"literais"|"logicos"
bloco_codigo "inicio"|"fim"
bloco_se "se"|"entao"|"senao"|"fim_se"
bloco_variaveis "variaveis"|"fim_variaveis"
bloco_para "para"|"de"|"ate"|"passo"|"fim_para"
bloco_enquanto "enquanto"|"faca"|"fim_enquanto"
bloco_funcao "funcao"|"retorne"
identificador ({letra}|"_")({letra}|{digito}|"_")*
inteiro {hexa}|{octal}|{binario}|{decimal}
real {decimal}"."{decimal}+
caractere \'([^\'\\]|\\.)?\'
string \"([^\"\\\n\r]|\\.)*\"
logico "verdadeiro"|"falso"
op_aritmetico "+"|"-"|"*"|"/"|"%"|"++"|"--"
op_binario "|"|"&"|"^"|"~"
op_relacional "<"|"<="|">"|">="|"="|"<>"
op_logico "e"|"ou"|"nao"
atribuicao ":="
especial "["|"]"|"("|")"|";"|","|":"

%%

{comentario_linha} {line_num++;}; /*ignorados*/
{comentario_bloco} {
    int i = 0;
    for (i = 0; i < strlen(yytext); i++) {
        if (yytext[i] == '\n')
            line_num++;
    }
}; /*ignorados*/
{especial} { 
	return yytext[0];
} ;
{op_logico} { 
	if (strcmp("e", yytext) == 0) 
		return OP_LOG_E; 
	if (strcmp("ou", yytext) == 0) 
		return OP_LOG_OU; 
	return OP_LOG_NAO;
} ;
{op_aritmetico} { 
	return yytext[0];
} ;
{op_binario} { 
	
	return yytext[0];
} ;
{op_relacional} { 
	if (strcmp("=", yytext) == 0) 
		return OP_REL_EQ; 
	if (strcmp("<>", yytext) == 0) 
		return OP_REL_INEQ; 
	if (strcmp(">", yytext) == 0) 
		return OP_REL_GT; 
	if (strcmp(">=", yytext) == 0) 
		return OP_REL_GTEQ; 
	if (strcmp("<", yytext) == 0) 
		return OP_REL_LT; 
	return OP_REL_LTEQ;
} ;
{atribuicao} { 
	return OP_ATR;
} ;
{inteiro}   {
	yylval.node = create_node(NULL, atoi(yytext), T_INT_LIT, 0);
	return T_INT_LIT; 
} ;
{real} {
	yylval.node = create_node(NULL, atof(yytext), T_REAL_LIT, 0); 
	return T_REAL_LIT;
} ;
{caractere} {
	yylval.node = create_node(NULL, yytext[0], T_CARAC_LIT, 0); 
	return T_CARAC_LIT;
} ;
{string} {
	yylval.node = create_node(string_frag(yytext), -1, T_STRING_LIT, 0); 
	return T_STRING_LIT;
} ;
{logico} {
	 
	if (strcmp("verdadeiro", yytext) == 0) {
		yylval.node = create_node(NULL, 1, T_KW_VERDADEIRO, 0); 
		return T_KW_VERDADEIRO; 
	}
	yylval.node = create_node(NULL, 0, T_KW_FALSO, 0);
	return T_KW_FALSO; 
} ;
"matriz" { 
	return MATRIZ; 
} ;
"algoritmo" { 
	return ALGORITMO; 
} ;
{bloco_se} { 
	
	if (strcmp("se", yytext) == 0) 
		return SE; 
	if (strcmp("entao", yytext) == 0) 
		return ENTAO; 
	if (strcmp("senao", yytext) == 0) 
		return SENAO; 
	return FIM_SE; 
} ;
{bloco_variaveis} { 
	
	if (strcmp("variaveis", yytext) == 0) 
		return VARIAVEIS; 
	return FIM_VARIAVEIS; 
};
{bloco_enquanto} { 
	
	if (strcmp("enquanto", yytext) == 0) 
		return ENQUANTO; 
	if (strcmp("faca", yytext) == 0) 
		return FACA; 
	return FIM_ENQUANTO; 
};
{bloco_para} { 
	
	if (strcmp("para", yytext) == 0) 
		return PARA; 
	if (strcmp("de", yytext) == 0) 
		return DE; 
	if (strcmp("ate", yytext) == 0) 
		return ATE; 
	if (strcmp("passo", yytext) == 0) 
		return PASSO; 
	return FIM_PARA; 
} ;
{bloco_funcao} { 
	
	if (strcmp("funcao", yytext) == 0) 
		return FUNCAO; 
	return RETORNE; 
};
{bloco_codigo} { 
	
	if (strcmp("inicio", yytext) == 0) 
		return INICIO;
	return FIM; 
};
{tp_prim} { 
	if (strcmp("literal", yytext) == 0) 
		return TP_LITERAL;
    if (strcmp("inteiro", yytext) == 0) 
		return TP_INTEIRO;
    if (strcmp("real", yytext) == 0) 
		return TP_REAL;
    if (strcmp("logico", yytext) == 0) 
		return TP_LOGICO;
    if (strcmp("caractere", yytext) == 0) 
		return TP_CARACTERE;
} ;
{tp_prim_plural} { 
    if (strcmp("literais", yytext) == 0) 
		return TP_LITERAIS;
    if (strcmp("inteiros", yytext) == 0) 
		return TP_INTEIROS;
    if (strcmp("reais", yytext) == 0) 
		return TP_REAIS;
    if (strcmp("logicos", yytext) == 0) 
		return TP_LOGICOS;
    if (strcmp("caracteres", yytext) == 0) 
		return TP_CARACTERES;
} ;
{identificador} {
    yylval.tp_identificador.linha_decl = line_num; 
	yylval.tp_identificador.label = malloc(strlen(yytext)+1); 
	strcpy(yylval.tp_identificador.label, yytext); 
	return T_IDENTIFICADOR;
} ;
[ \t]     ; /* ignorados */
\n      { line_num++; } ; /* ignorado */
<<EOF>> { return 0; };
[^ \t\n]     { return DESCONHECIDO;} ;


%%

//Remove as aspas da string
char* string_frag(char* string) {
	int size = strlen(string);
	int i;
	char* new_string = malloc(strlen(string) - 1);
	for (i = 1; i < (size - 1); i++) {
		new_string[i-1] = string[i];
	}
	new_string[i-1] = '\0';
	return new_string;
}