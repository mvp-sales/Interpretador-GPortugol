/* A Bison parser, made by GNU Bison 3.0.2.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2013 Free Software Foundation, Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

#ifndef YY_YY_PARSER_H_INCLUDED
# define YY_YY_PARSER_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 0
#endif
#if YYDEBUG
extern int yydebug;
#endif
/* "%code requires" blocks.  */
#line 1 "parser.y" /* yacc.c:1909  */

    #include "ast.h"
    #include "funcoes.h"
    #include "runner.h"

#line 50 "parser.h" /* yacc.c:1909  */

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    T_IDENTIFICADOR = 258,
    T_STRING_LIT = 259,
    T_CARAC_LIT = 260,
    T_INT_LIT = 261,
    T_REAL_LIT = 262,
    T_KW_VERDADEIRO = 263,
    T_KW_FALSO = 264,
    TP_INTEIRO = 265,
    TP_REAL = 266,
    TP_LITERAL = 267,
    TP_LOGICO = 268,
    TP_CARACTERE = 269,
    TP_INTEIROS = 270,
    TP_REAIS = 271,
    TP_LITERAIS = 272,
    TP_LOGICOS = 273,
    TP_CARACTERES = 274,
    OP_REL_EQ = 275,
    OP_REL_INEQ = 276,
    OP_REL_GT = 277,
    OP_REL_GTEQ = 278,
    OP_REL_LT = 279,
    OP_REL_LTEQ = 280,
    OP_ATR = 281,
    OP_LOG_E = 282,
    OP_LOG_OU = 283,
    OP_LOG_NAO = 284,
    ALGORITMO = 285,
    MATRIZ = 286,
    VARIAVEIS = 287,
    FIM_VARIAVEIS = 288,
    INICIO = 289,
    FIM = 290,
    SE = 291,
    ENTAO = 292,
    SENAO = 293,
    FIM_SE = 294,
    PARA = 295,
    DE = 296,
    ATE = 297,
    PASSO = 298,
    FIM_PARA = 299,
    ENQUANTO = 300,
    FACA = 301,
    FIM_ENQUANTO = 302,
    FUNCAO = 303,
    RETORNE = 304,
    DESCONHECIDO = 305
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
typedef union YYSTYPE YYSTYPE;
union YYSTYPE
{
#line 20 "parser.y" /* yacc.c:1909  */

    //Usada para detalhar o tipo de primitivos
    unsigned tp_expr;
    //Usada para detalha o tipo/valor de constantes, usado para AST
    Node* node;
    //Usada para montar as árvores de expressões
    //conforme são encontradas
    struct str_expr_typecheck {
        char* funcao; //detalha se há uma função ainda não declarada no nó da árvore
        unsigned tipo;
        unsigned linha_chamada;
        void* expr; //árvore de tipos da expressão
        Node* node; //usado para a criação da AST
    } tp_expr_typecheck;
    //Usada para detalhar identificadores,
    //utilizados por funções/variáveis
    struct struct_identificador {
	    char* label; //nome do identificador
        unsigned linha_decl; //linha em que foi declarado
    } tp_identificador;
    //Usada pelos fargs durante chamadas à função
    struct str_fargs_type {
        int size; //quantidade de argumentos
        void* expr_forest; //floresta das árvores de tipos das expressões que detalha o que
                           //está sendo passado como argumento à função
        AST_FOREST* ast_forest; //usado para a criação da AST
    } fargs_type;
    //Usada para controlar as listas de variáveis pré-inserção
    //nas tabelas hash
    void* lista_var;

#line 145 "parser.h" /* yacc.c:1909  */
};
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_PARSER_H_INCLUDED  */
