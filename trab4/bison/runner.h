#ifndef RUNNER_H
#define RUNNER_H

#include "ast.h"
#include "pilha.h"
#include "parser.h"
#include <stdio.h>
#include "variaveis.h"

//Operações aritméticas
void run_ast_plus(Node* n);
void run_ast_minus(Node* n);
void run_ast_mult(Node* n);
void run_ast_div(Node* n);
void run_ast_mod(Node* n);
void run_ast_uplus(Node* n);
void run_ast_uminus(Node* n);

void run_ast_lt(Node* n);
void run_ast_lteq(Node* n);
void run_ast_eq(Node* n);
void run_ast_ineq(Node* n);
void run_ast_gt(Node* n);
void run_ast_gteq(Node* n);
void run_ast_or(Node* n);
void run_ast_and(Node* n);
void run_ast_not(Node* n);

void run_ast_attr(Node* n);
void run_ast_if(Node* n);
void run_ast_while(Node* n);
void run_ast_for(Node* n);
void run_ast_func(Node* n);
void run_ast_var(Node* n);
void run_ast_block(Node* n);
void run_ast_ret(Node* n);

void print_value(Node* n);

void rec_run_ast(Node* n);
void run_ast(Node* n);

char* scope;

#endif
