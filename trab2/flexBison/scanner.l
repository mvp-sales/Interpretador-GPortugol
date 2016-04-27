%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%{
#include <stdio.h>
#include <string.h>
#include "parser.h"
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
op_aritmetico "+"|"-"|"*"|"/"|"%"|"~"|"++"|"--"
op_binario "|"|"&"|"^"
op_relacional "<"|"<="|">"|">="|"="|"<>"
op_logico "e"|"ou"|"nao"
atribuicao ":="
especial "["|"]"|"("|")"|";"|","|":"

%%

{comentario_linha} ; /*ignorados*/
{comentario_bloco} ; /*ignorados*/
{especial}    { printf("%s -> ESPECIAL\n", yytext); return yytext[0];} ;
{logico}    { printf("%s -> LOGICO\n", yytext); if (strcmp("verdadeiro", yytext) == 0) { return T_KW_VERDADEIRO; } else { return T_KW_FALSO; } } ;
{op_logico}    { printf("%s -> OP_LOGICO\n", yytext); if (strcmp("e", yytext) == 0) return OP_LOG_E; else if (strcmp("ou", yytext) == 0) return OP_LOG_OU; else return OP_LOG_NAO;} ;
{op_aritmetico}    { printf("%s -> OP_ARIT\n", yytext); return yytext[0];} ;
{op_binario}    { printf("%s -> OP_BIN\n", yytext); return yytext[0];} ;
{op_relacional}    { printf("%s -> OP_REL\n", yytext); if (strcmp("=", yytext) == 0) return OP_REL_EQ; else if (strcmp("<>", yytext) == 0) return OP_REL_INEQ; else if (strcmp(">", yytext) == 0) return OP_REL_GT; else if (strcmp(">=", yytext) == 0) return OP_REL_GTEQ; else if (strcmp("<", yytext) == 0) return OP_REL_LT; else return OP_REL_LTEQ;} ;
{inteiro}   { printf("%s -> INTEIRO\n", yytext); return T_INT_LIT; } ;
{real} { printf("%s -> REAL\n", yytext); return T_REAL_LIT;} ;
{caractere} { printf("%s -> CARACTERE\n", yytext); return T_CARAC_LIT;} ;
{string}    { printf("%s -> STRING\n", yytext); return T_STRING_LIT;} ;
"matriz" { printf("%s -> MATRIZ\n", yytext); return MATRIZ; } ;
"algoritmo" { printf("%s -> ALGORITMO\n", yytext); return ALGORITMO; } ;
{tp_prim} { printf("%s -> TIPO_PRIM\n", yytext); return TP_PRIM; } ;
{tp_prim_plural} { printf("%s -> TIPO_PRIM_PLURAL\n", yytext); return TP_PRIM_PL; } ;
{bloco_se} { printf("%s -> BLOCO_SE\n", yytext); if (strcmp("se", yytext) == 0) return SE; else if (strcmp("entao", yytext) == 0) return ENTAO; else if (strcmp("senao", yytext) == 0) return SENAO; else return FIM_SE; } ;
{bloco_variaveis} { printf("%s -> BLOCO_VAR\n", yytext); if (strcmp("variaveis", yytext) == 0) return VARIAVEIS; else return FIM_VARIAVEIS; };
{bloco_enquanto} { printf("%s -> BLOCO_ENQ\n", yytext); if (strcmp("enquanto", yytext) == 0) return ENQUANTO; else if (strcmp("faca", yytext) == 0) return FACA; else return FIM_ENQUANTO; };
{bloco_para} { printf("%s -> BLOCO_PARA\n", yytext); if (strcmp("para", yytext) == 0) return PARA; else if (strcmp("de", yytext) == 0) return DE; else if (strcmp("ate", yytext) == 0) return ATE; else if (strcmp("passo", yytext) == 0) return PASSO; else return FIM_PARA; } ;
{bloco_funcao} { printf("%s -> BLOCO_FNC\n", yytext); if (strcmp("funcao", yytext) == 0) return FUNCAO; else return RETORNE; };
{bloco_codigo} { printf("%s -> BLOCO_COD\n", yytext); if (strcmp("inicio", yytext) == 0) return INICIO; else return FIM; };
{atribuicao}    { printf("%s -> OP_ATR\n", yytext); return OP_ATR;} ;
{identificador} { printf("%s -> IDENTIFICADOR\n", yytext); return T_IDENTIFICADOR;} ;
[ \t\n]     ; /* ignorados */
[^ \t\n]     { printf("%s -> DESCONHECIDO\n", yytext); return DESCONHECIDO;} ;

%%
