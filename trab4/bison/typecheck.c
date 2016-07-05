#include "funcoes.h"

type_check* new_typecheck(char* funcao, unsigned tipo_esperado, unsigned linha_chamada, int operacao, type_check* esq, type_check* dir) {
    type_check* new_tc = malloc(sizeof(type_check));
    new_tc->funcao = funcao;
    new_tc->tipo_esperado = tipo_esperado;
    new_tc->linha_chamada = linha_chamada;
    new_tc->operacao = operacao;
    new_tc->esq = esq;
    new_tc->dir = dir;
    return new_tc;
}

void set_expr_type(type_check* expr, unsigned tipo) {
    expr->tipo_esperado = tipo;
}

type_check_forest* add_to_forest(type_check* tree, type_check_forest* forest) {
    type_check_forest* tcf = malloc(sizeof(type_check_forest));
    tcf->prox = NULL;
    tcf->tree = tree;
    if (forest != NULL) {
        type_check_forest* aux = forest;
        while (aux->prox != NULL)
            aux = aux->prox;
        aux->prox = tcf;
        return forest;
    }
    return tcf;
}

void verify_typecheck(type_check* tree) {
    if (tree != NULL) {
        verify_typecheck(tree->esq);
        verify_typecheck(tree->dir);
        if (tree->tipo_esperado == INDEFINIDO) {
            //Existe uma função nesta chamada que ainda não tinha sido declarada
            tbl_funcoes* f;
            f = lookup_fnc(tree->funcao);
            set_expr_type(tree, f->retorno);
        }
        else if (tree->funcao != NULL) {
            //existe uma função nesta chamada (caso de exigência quando a função é imediatamente atribuída à variável)
            tbl_funcoes* f;
            f = lookup_fnc(tree->funcao);
            if (tree->tipo_esperado == NUMERICO && f->retorno != INTEIRO && f->retorno != REAL) {
                fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", tree->linha_chamada);
                exit(1);
            }
            if (f->retorno != tree->tipo_esperado) {
                fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", tree->linha_chamada);
                exit(1);
            }
        }
        else if (tree->tipo_esperado == NUMERICO) {
            if (tree->esq != NULL && tree->dir != NULL) {
                //operações aritméticas
                set_expr_type(tree, expr_op_arit(tree->esq->tipo_esperado, tree->dir->tipo_esperado, tree->linha_chamada));
            }
            else {
                //operaçoes unárias (+, -)
                set_expr_type(tree, expr_op_unary(tree->esq->tipo_esperado, tree->linha_chamada));
            }
        }
        else if (tree->tipo_esperado == INTEIRO) {
            if (tree->esq != NULL && tree->dir != NULL) {
                //operações binárias/mod/arit puramente com inteiro (possuem o mesmo retorno para todas as comparações)
                expr_op_bin(tree->esq->tipo_esperado, tree->dir->tipo_esperado, tree->linha_chamada);
            }
            else if (tree->esq != NULL) {
                //operação unária bitwise (~)
                expr_op_unot(tree->esq->tipo_esperado, tree->linha_chamada);
            }
        }
        else if (tree->tipo_esperado == REAL) {
            //Pelo menos um dos elementos é real
            if (tree->esq != NULL && tree->dir != NULL) {
                //operações aritméticas
                expr_op_arit(tree->esq->tipo_esperado, tree->dir->tipo_esperado, tree->linha_chamada);
            }
            //A operação unária (+, -) só retorna real se o elemento for real de fato, logo não necessita ser checada
        }
        else {
            //Lógico
            if (tree->esq != NULL && tree->dir != NULL) {
                //operações relacionais ou lógicas
                if (tree->operacao == OP_LOG)
                    expr_op_log(tree->esq->tipo_esperado, tree->dir->tipo_esperado, tree->linha_chamada);
                else if (tree->operacao == OP_REL_EQL || tree->operacao == OP_REL_INEQL)
                    expr_op_rel_eqineq(tree->esq->tipo_esperado, tree->dir->tipo_esperado, tree->linha_chamada);
                else
                    expr_op_rel_cmp(tree->esq->tipo_esperado, tree->dir->tipo_esperado, tree->linha_chamada);
            }
            else if (tree->esq != NULL) {
                //operação unária not
                expr_op_not(tree->esq->tipo_esperado, tree->linha_chamada);
            }
        }
        if (tree->esq != NULL)
            free(tree->esq);
        if (tree->dir != NULL)
            free(tree->dir);
    }
}

void verify_all_typechecks(type_check_forest* forest) {
    while(forest != NULL) {
        type_check_forest* tcf = forest->prox;
        verify_typecheck(forest->tree);
        free(forest->tree);
        free(forest);
        forest = tcf;
    }
}

unsigned expr_op_log(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t1 == LITERAL || t2 == LITERAL || t1 == CARACTERE || t2 == CARACTERE || t1 == VOID || t2 == VOID) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == NUMERICO || t2 == NUMERICO || t1 == INTEIRO || t2 == INTEIRO || t1 == REAL || t2 == REAL || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return LOGICO;
}

unsigned expr_op_rel_cmp(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t1 == VOID || t2 == VOID || t1 == LOGICO || t2 == LOGICO || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == LITERAL || t2 == LITERAL || t1 == CARACTERE || t2 == CARACTERE) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return LOGICO;
}

unsigned expr_op_rel_eqineq(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t1 == VOID || t2 == VOID || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == t2)
        return LOGICO;
    if (t1 != INDEFINIDO && t2 != INDEFINIDO) {
        if (t1 == NUMERICO || t2 == NUMERICO) {
            if (t1 == REAL || t1 == INTEIRO)
                return LOGICO;
            if (t2 == REAL || t2 == INTEIRO)
                return LOGICO;
        }
        else if ((t1 == INTEIRO && t2 == REAL) || (t1 == REAL && t2 == INTEIRO))
            return LOGICO;
        //Tipos não-compatíveis
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return LOGICO;
}

unsigned expr_op_arit(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t1 == LITERAL || t2 == LITERAL || t1 == CARACTERE || t2 == CARACTERE || t1 == VOID || t2 == VOID) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == LOGICO || t2 == LOGICO || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == REAL || t2 == REAL)
        return REAL;
    if (t1 == INTEIRO && t2 == INTEIRO)
        return INTEIRO;
    return NUMERICO;
}

unsigned expr_op_mod(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t1 == LITERAL || t2 == LITERAL || t1 == CARACTERE || t2 == CARACTERE || t1 == VOID || t2 == VOID) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == LOGICO || t2 == LOGICO || t1 == REAL || t2 == REAL || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return INTEIRO;
}

unsigned expr_op_not(unsigned t1, unsigned linha_chamada) {
    if (t1 == LITERAL || t1 == CARACTERE || t1 == VOID) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == NUMERICO || t1 == INTEIRO ||  t1 == REAL || eh_matriz(t1)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return LOGICO;
}

unsigned expr_op_unary(unsigned t1, unsigned linha_chamada) {
    if (t1 == LITERAL || t1 == CARACTERE || t1 == VOID || t1 == LOGICO || eh_matriz(t1)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == REAL)
        return REAL;
    if (t1 == INTEIRO)
        return INTEIRO;
    return NUMERICO;
}

unsigned expr_op_bin(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t1 == LITERAL || t2 == LITERAL || t1 == CARACTERE || t2 == CARACTERE || t1 == VOID || t2 == VOID) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t1 == LOGICO || t2 == LOGICO || t1 == REAL || t2 == REAL || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return INTEIRO;
}

unsigned expr_op_unot(unsigned t1, unsigned linha_chamada) {
    if (t1 == LITERAL || t1 == CARACTERE || t1 == VOID || t1 == LOGICO || t1 == REAL || eh_matriz(t1)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    return INTEIRO;
}

unsigned expr_op_attr(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t2 == VOID || eh_matriz(t1) || eh_matriz(t2)) {
        fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
        exit(1);
    }
    if (t2 != INDEFINIDO) {
        if (t2 == NUMERICO) {
            if (t1 == INTEIRO)
                return INTEIRO;
            if (t1 == REAL)
                return NUMERICO;
            fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
            exit(1);
        }
        else if (t2 == INTEIRO) {
            if (t1 == INTEIRO || t1 == REAL)
                return INTEIRO;
            fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
            exit(1);
        }
        else if (t2 == REAL) {
            if (t1 == INTEIRO || t1 != t2) {
                fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
                exit(1);
            }
            return REAL;
        }
        else if (t1 != t2) {
            fprintf(stderr, "Erro semantico na linha %d: expressao com tipos de dados incompatíveis.\n", linha_chamada);
            exit(1);
        }
        return t1;
    }
    if (t1 == REAL)
        return NUMERICO;
    return t1;
}

//Passagem de argumentos para funções
unsigned expr_op_pass(unsigned t1, unsigned t2, unsigned linha_chamada) {
    if (t2 == INDEFINIDO) {
        if (t1 == REAL)
            return NUMERICO;
        return t1;
    }
    if (t2 == t1)
        return t1;
    //Se comporta de forma similar à operação de atribuição para outros casos
    return expr_op_attr(t1, t2, linha_chamada);
}

unsigned eh_matriz(unsigned tipo) {
    return tipo == MATRIZ_LITERAIS || tipo == MATRIZ_LOGICOS || tipo == MATRIZ_CARACTERES || tipo == MATRIZ_REAIS || tipo == MATRIZ_INTEIROS;
}
