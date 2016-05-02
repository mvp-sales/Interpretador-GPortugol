%option outfile="scanner.c"
%option noyywrap
%option nounput
%option noinput
%{
#include <stdio.h>
#include <string.h>
#include "parser.h"
extern int node;
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

{comentario_linha} ; /*ignorados*/
{comentario_bloco} ; /*ignorados*/
{especial}    { yylval.t_node = node; node++; return yytext[0];} ;
{op_logico}    { yylval.t_node = node; node++; if (strcmp("e", yytext) == 0) return OP_LOG_E; else if (strcmp("ou", yytext) == 0) return OP_LOG_OU; else return OP_LOG_NAO;} ;
{op_aritmetico}    { yylval.t_node = node; node++; return yytext[0];} ;
{op_binario}    { yylval.t_node = node; node++; return yytext[0];} ;
{op_relacional}    { yylval.t_node = node; node++; if (strcmp("=", yytext) == 0) return OP_REL_EQ; else if (strcmp("<>", yytext) == 0) return OP_REL_INEQ; else if (strcmp(">", yytext) == 0) return OP_REL_GT; else if (strcmp(">=", yytext) == 0) return OP_REL_GTEQ; else if (strcmp("<", yytext) == 0) return OP_REL_LT; else return OP_REL_LTEQ;} ;
{atribuicao}    { yylval.t_node = node; node++; return OP_ATR;} ;
{inteiro}   { yylval.t_value_num.node = node; node++; yylval.t_value_num.value = atoi(yytext); return T_INT_LIT; } ;
{real} { yylval.t_value_num.node = node; node++; yylval.t_value_num.value = atof(yytext); return T_REAL_LIT;} ;
{caractere} { yylval.t_value_carac.node = node; node++; if (yytext[1] == '\'') yylval.t_value_carac.value = '\0'; else yylval.t_value_carac.value = yytext[1]; return T_CARAC_LIT;} ;
{string}    { yylval.t_value_string.node = node; node++; yylval.t_value_string.value = malloc(strlen(yytext)+1); strcpy(yylval.t_value_string.value, yytext); return T_STRING_LIT;} ;
{logico}    { yylval.t_value_bool.node = node; node++; yylval.t_value_bool.value = malloc(strlen(yytext)+1); strcpy(yylval.t_value_bool.value, yytext); if (strcmp("verdadeiro", yytext) == 0) {  return T_KW_VERDADEIRO; } else { return T_KW_FALSO; } } ;
"matriz" { yylval.t_node = node; node++; return MATRIZ; } ;
"algoritmo" { yylval.t_node = node; node++; return ALGORITMO; } ;
{bloco_se} { yylval.t_node = node; node++; if (strcmp("se", yytext) == 0) return SE; else if (strcmp("entao", yytext) == 0) return ENTAO; else if (strcmp("senao", yytext) == 0) return SENAO; else return FIM_SE; } ;
{bloco_variaveis} { yylval.t_node = node; node++; if (strcmp("variaveis", yytext) == 0) return VARIAVEIS; else return FIM_VARIAVEIS; };
{bloco_enquanto} { yylval.t_node = node; node++; if (strcmp("enquanto", yytext) == 0) return ENQUANTO; else if (strcmp("faca", yytext) == 0) return FACA; else return FIM_ENQUANTO; };
{bloco_para} { yylval.t_node = node; node++; if (strcmp("para", yytext) == 0) return PARA; else if (strcmp("de", yytext) == 0) return DE; else if (strcmp("ate", yytext) == 0) return ATE; else if (strcmp("passo", yytext) == 0) return PASSO; else return FIM_PARA; } ;
{bloco_funcao} { yylval.t_node = node; node++; if (strcmp("funcao", yytext) == 0) return FUNCAO; else return RETORNE; };
{bloco_codigo} { yylval.t_node = node; node++; if (strcmp("inicio", yytext) == 0) return INICIO; else return FIM; };
{tp_prim} { yylval.t_label_struct.node = node; node++; yylval.t_label_struct.label = malloc(strlen(yytext)+1); strcpy(yylval.t_label_struct.label, yytext); return TP_PRIM; } ;
{tp_prim_plural} { yylval.t_label_struct.node = node; node++; yylval.t_label_struct.label = malloc(strlen(yytext)+1); strcpy(yylval.t_label_struct.label, yytext); return TP_PRIM_PL; } ;
{identificador} { yylval.t_label_struct.node = node; node++; yylval.t_label_struct.label = malloc(strlen(yytext)+1); strcpy(yylval.t_label_struct.label, yytext); return T_IDENTIFICADOR;} ;
[ \t\n]     ; /* ignorados */
<<EOF>> { return 0; };
[^ \t\n]     { return DESCONHECIDO;} ;


%%
