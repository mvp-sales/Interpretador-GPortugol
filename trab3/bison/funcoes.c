#include "funcoes.h"

//Procura a função especificada na tabela de funções
tbl_funcoes* lookup_fnc(char* nome) {
	tbl_funcoes* hf;
	unsigned pos = hash_func(nome, strlen(nome));
	hf = hashmap_func[pos].tbl_fnc;
	while (hf != NULL) {
		if (strcmp(hf->nome, nome) == 0)
			return hf;
		hf = hf->prox;
	}
	return NULL;
}

//Insere uma nova função na tabela de símbolos global para funções
tbl_funcoes* insert_fnc(char* nome, unsigned linha_decl, int aridade, unsigned retorno, int declarada, tbl_variaveis* fparams) {
    tbl_funcoes* elem_found = lookup_fnc(nome);
    if (elem_found == NULL) {
		//Função não existe na tabela hash
        int pos = hash_func(nome, strlen(nome));
		int i;
        tbl_funcoes* new_func = malloc(sizeof(tbl_funcoes));
        new_func->nome = malloc(1+strlen(nome));
        strcpy(new_func->nome, nome);
        new_func->linha_decl = linha_decl;
        new_func->aridade = aridade;
        new_func->retorno = retorno;
        new_func->declarada = declarada;
				new_func->tipos_esperados = malloc(aridade*sizeof(unsigned));
        new_func->fcalls = NULL;
        //Cria a tabela hash de variáveis da função
        new_func->hash_var = malloc(HASH_SIZE*sizeof(hashmap_var));
        for (i = 0; i < HASH_SIZE; i++) {
            new_func->hash_var[i].tbl_var = NULL;
        }
		//Insere na tabela hash de funções a nova função
		tbl_funcoes* tf = hashmap_func[pos].tbl_fnc;
        if (tf == NULL) {
            hashmap_func[pos].tbl_fnc = new_func;
            new_func->prox = NULL;
        }
        else {
            new_func->prox = tf;
            hashmap_func[pos].tbl_fnc = new_func;
        }
        //Define os tipos esperados como argumentos
        tbl_variaveis* fp = fparams;
        for (i = 0; i < aridade; i++) {
            new_func->tipos_esperados[i] = fp->tipo;
            fp = fp->prox;
        }
        //Insere os parâmetros da função na hash de variáveis da função
        insert_multi_var(fparams, new_func->hash_var);
        return new_func;
    }
    else if (!elem_found->declarada) {
		//Função já existe, mas não foi declarada
        elem_found->linha_decl = linha_decl;
        elem_found->aridade = aridade;
        elem_found->retorno = retorno;
        elem_found->declarada = declarada;
        elem_found->tipos_esperados = malloc(aridade*sizeof(unsigned));
        int i;
        //Define os tipos esperados como argumentos
        tbl_variaveis* fp = fparams;
        for (i = 0; i < aridade; i++) {
            elem_found->tipos_esperados[i] = fp->tipo;
            fp = fp->prox;
        }
        //Insere os parâmetros da função na hash de variáveis da função
        insert_multi_var(fparams, elem_found->hash_var);
        return elem_found;
    }
    else {
        fprintf(stderr, "Erro semantico na linha %d: função '%s' ja foi declarada na linha %d\n", linha_decl, nome, elem_found->linha_decl);
        exit(1);
    }
}

//Retorna a tabela de simbolos para variáveis da função
hashmap_var get_fnc_hashmap_var(char* func) {
    tbl_funcoes* elem_found = lookup_fnc(func);
    return elem_found->hash_var;
}

//Altera o escopo atual para novo escopo
void muda_escopo(char* novo_escopo, char** escopo_atual) {
    if (*escopo_atual != NULL)
        free(*escopo_atual);
    *escopo_atual = malloc(1+strlen(novo_escopo));
    strcpy(*escopo_atual, novo_escopo);
}

//Confere se os tipos de argumentos especificados conferem com os parâmetros da função
void check_params(char* funcao, type_check_forest* args) {
    tbl_funcoes* f = lookup_fnc(funcao);
    int i;
    type_check_forest* tf;
    for (i = 0; i < f->aridade; i++) {
        tf = args;
				//Faz o ajuste de tipo necessário para a expressão com base no tipo esperado do parâmetro
        set_expr_type(args->tree, expr_op_pass(f->tipos_esperados[i], args->tree->tipo_esperado, args->tree->linha_chamada));
				//Adiciona a expressão do argumento à floresta global de expressões
        add_to_forest(args->tree, tc_forest);
        args = args->prox;
        free(tf);
    }
}

//Adiona uma nova chamada à função especificada
void new_call(char* funcao, type_check_forest* expr_forest, unsigned linha_chamada) {
    fcall* new_fcall = malloc(sizeof(fcall));
    int nargs = 0;
    type_check_forest* ef = expr_forest;
    while (ef != NULL) {
        nargs++;
        ef = ef->prox;
        //O número de argumentos equivale à quantidade de árvores contidas na floresta de expressões
    }
    new_fcall->nargs = nargs;
    new_fcall->expr_forest = expr_forest;
    new_fcall->linha_chamada = linha_chamada;
    new_fcall->prox = NULL;
    tbl_funcoes* tf = lookup_fnc(funcao);
    if (tf == NULL) {
		//A função não existe, então crie uma função temporária até a declaração
        tf = insert_fnc(funcao, 0, 0, INDEFINIDO, 0, NULL);
        tf->fcalls = new_fcall;
    }
    else {
		//Adiciona a chamada à lista de chamadas da função
        fcall* fc = tf->fcalls;
        while(fc->prox != NULL)
            fc = fc->prox;
        fc->prox = new_fcall;
    }
}

//Confere se as chamadas que foram realizadas antes da declaração da função
//atendem aos requisitos necessários
void accept_calls(tbl_funcoes* func) {
    while (func->fcalls != NULL) {
        fcall* fc = func->fcalls;
        if ((func->aridade == -1 && fc->nargs == 0) || (fc->nargs != func->aridade)) {
            //Erro de aridade
            fprintf(stderr, "Erro semantico na linha %d: a funcao '%s' foi chamada com %d argumentos mas declarada com %d parâmetros.\n", fc->linha_chamada, func->nome, fc->nargs, func->aridade);
            exit(1);
        }
        //Avalia se os tipos usados na chamada correspondem aos tipos dos parâmetros da função
        check_params(func->nome, fc->expr_forest);
        func->fcalls = fc->prox;
        free(fc);
    }
}

//Se existem ainda chamadas que não foram atendidas (funções não declaradas), retornar a que ocorreu primeiro
tbl_funcoes* all_calls_accepted(hashmap_fnc hash) {
    int i = 0;
    int menor = -1;
    tbl_funcoes* chamada_mais_antiga = NULL;
    tbl_funcoes* tf;
    for (i = 0; i < HASH_SIZE; i++) {
        tf = hash[i].tbl_fnc;
        while (tf != NULL) {
            if (!tf->declarada) {
                if (menor == -1) {
                    menor = tf->fcalls->linha_chamada;
                    chamada_mais_antiga = tf;
                }
                else if (tf->fcalls->linha_chamada < menor) {
                    menor = tf->fcalls->linha_chamada;
                    chamada_mais_antiga = tf;
                }
            }
            tf = tf->prox;
        }
    }
    return chamada_mais_antiga;
}
