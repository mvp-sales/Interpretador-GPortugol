/* Alunos:
		Gabriel Correa de Macena
		Marcus Vinicius Palassi Sales
*/
%{
#include <stdio.h>
%}

digito  [0-9]
letra [a-zA-Z]
comentario_linha "//"[^\n]*
comentario_bloco "/*"(("*"[^'/'])|[^"*"])*"*/"
hexa 0[Xx]({digito}|[A-Fa-f])+
octal 0[Cc][0-7]+
binario 0[Bb][01]+
decimal {digito}+
reservada "fim_variaveis"|"algoritmo"|"variaveis"|("inteiro"("s"?))|("rea"("l"|"is"))|("caractere"("s"?))|("litera"("l"|"is"))|("logico"("s"?))|"inicio"|"fim"|{logico}|{op_logico}|"se"|"senao"|"entao"|("fim_"("se"|"enquanto"|"para"))|"enquanto"|"faca"|"para"|"de"|"ate"|"matriz"|"funcao"|"retorne"|"passo"
identificador ({letra}|"_")({letra}|{digito}|"_")*
inteiro {hexa}|{octal}|{binario}|(("+"|"-")?{decimal})
real ("+"|"-")?{decimal}"."{decimal}+
caractere \'([^\'\\]|\\.)?\'
string \"([^\"\\\n\r]|\\.)*\"
logico "verdadeiro"|"falso"
op_aritmetico "+"|"-"|"*"|"/"|"%"|"++"|"--"
op_relacional "<"|"<="|">"|">="|"="|"<>"
op_logico "e"|"ou"|"nao"
atribuicao ":="
especial "["|"]"|"("|")"|";"|","|":"

/* No trabalho foi feita a escolha de representar inteiros com sinal, 
 portanto, expressoes como por exemplo, "z-1", sao "tokenizados" como 
 z como identificador e -1 como inteiro (caso haja espaço entre o numero e o sinal, 
 o - eh tokenizado como operador e o 1 como inteiro.
 Foi tentado o uso de trailing context e start conditions para ter um lexer sensivel ao 
 contexto, mas nao deu certo. */

%%
{comentario_linha} ; /*ignorados*/
{comentario_bloco} ; /*ignorados*/
{especial}    { printf("%s -> SIMBOLO_ESPECIAL\n", yytext); }
{logico}    { printf("%s -> LOGICO\n", yytext); }
{op_logico}    { printf("%s -> OPERADOR_LOGICO\n", yytext); }
{op_aritmetico}    { printf("%s -> OPERADOR_ARITMETICO\n", yytext); }
{op_relacional}    { printf("%s -> OPERADOR_RELACIONAL\n", yytext); }
{inteiro}   { printf("%s -> INTEIRO\n", yytext); }
{real} { printf("%s -> REAL\n", yytext);}
{caractere} { printf("%s -> CARACTERE\n", yytext); }
{string}    { printf("%s -> LITERAL\n", yytext); }
{reservada}    { printf("%s -> PALAVRA_RESERVADA\n", yytext); }
{atribuicao}    { printf("%s -> ATRIBUICAO\n", yytext); }
{identificador} { printf("%s -> IDENTIFICADOR\n", yytext); }
[^ \t\n]     { printf("%s -> DESCONHECIDO\n", yytext); }
[ \t\n]     ; /* ignorados */
<<EOF>>     { return 0; }
%%
int main() { yylex(); return 0; }
/* Definindo esta funcao nao precisa compilar com -lfl */
int yywrap() { return 1; }
