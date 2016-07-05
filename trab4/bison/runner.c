#include "runner.h"

void run_ast_plus(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  push(pop() + pop());
}


void run_ast_minus(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() - r);
}


void run_ast_mult(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  push(pop() * pop());
}


void run_ast_div(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() / r);
}


void run_ast_mod(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() % r);
}


void run_ast_uplus(Node* n) {
  rec_run_ast(n->children[0]);
  push(+ pop());
}


void run_ast_uminus(Node* n) {
  rec_run_ast(n->children[0]);
  push(- pop());
}


void run_ast_lt(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() < r);
}


void run_ast_lteq(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() <= r);
}


void run_ast_eq(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() == r);
}


void run_ast_ineq(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() != r);
}


void run_ast_gt(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() > r);
}


void run_ast_gteq(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  push(pop() >= r);
}


void run_ast_or(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  int l = pop();
  push(l || r);
}


void run_ast_and(Node* n) {
  rec_run_ast(n->children[0]);
  rec_run_ast(n->children[1]);
  int r = pop();
  int l = pop();
  push(l && r);
}

void run_ast_not(Node* n) {
  rec_run_ast(n->children[0]);
  push(!pop());
}


void run_ast_attr(Node* n) {
  rec_run_ast(n->children[1]);
  tbl_variaveis* tv;
  if (scope == NULL)
    tv  = lookup_var(n->children[0]->name, hashmap_var_bloco_principal);
  else
    tv = lookup_var(n->children[0]->name, get_fnc_hashmap_var(scope)); 
  tv->value = pop();
}


void run_ast_if(Node* n) {
  rec_run_ast(n->children[0]);
  if (pop()) {
    rec_run_ast(n->children[1]);
  }
  else if (n->numchildren == 3) {
    rec_run_ast(n->children[2]);
  }
}


void run_ast_while(Node* n) {
  rec_run_ast(n->children[0]);
  if (pop()) {
    rec_run_ast(n->children[1]);
    run_ast_while(n);
  }
}


void run_ast_for(Node* n) {
  Node* na = create_node(NULL, -1, OP_ATR, 2);
  add_child(na, n->children[0]);
  add_child(na, n->children[1]);
  rec_run_ast(na);

  tbl_variaveis* tv;
  if (scope == NULL)
    tv = lookup_var(n->children[0]->name, hashmap_var_bloco_principal);
  else
    tv = lookup_var(n->children[0]->name, get_fnc_hashmap_var(scope));

  rec_run_ast(n->children[2]);
  int max = pop();

  int passo = 1;
  if (n->numchildren == 5) {
    rec_run_ast(n->children[3]);
    passo = pop();
  }
  if (passo > 0) {
    while (tv->value <= max) {
      rec_run_ast(n->children[n->numchildren-1]);
      tv->value = tv->value + passo;
    }
  }
  else {
    while (tv->value >= max) {
      rec_run_ast(n->children[n->numchildren-1]);
      tv->value = tv->value + passo;
    }
  }
}


void run_ast_func(Node* n) {
  if (strcmp(n->name, "imprima") == 0) {
    print_value(n);
    return;
  }
  scope = n->name;
  tbl_funcoes* tf = lookup_fnc(n->name);
  int i;
  for (i = n->numchildren-1; i >= 0; i--) {
    rec_run_ast(n->children[i]);
  }
  for (i = 0; i < tf->aridade; i++) {
    tbl_variaveis* tv = lookup_var(tf->params[i]->name, tf->hash_var);
    tv->value = pop();
  }
  rec_run_ast(tf->block);
}


void run_ast_var(Node* n) {
  tbl_variaveis* tv;
  if (scope == NULL)
    tv  = lookup_var(n->name, hashmap_var_bloco_principal);
  else
    tv = lookup_var(n->name, get_fnc_hashmap_var(scope));
  push(tv->value);
}


void run_ast_block(Node* n) {
  int i;
  for (i = 0; i < n->numchildren; i++) {
    rec_run_ast(n->children[i]);
  }
}


void run_ast_ret(Node* n) {
  if (n->numchildren > 0) {
    rec_run_ast(n->children[0]);
  }
}


void print_value(Node* n) {
  switch(n->children[0]->type) {
    case T_STRING_LIT:
      printf("%s\n", n->children[0]->name);
      break;
    default:
      rec_run_ast(n->children[0]);
      printf("%d\n", pop());
      break;
  }
}


void rec_run_ast(Node* n) {
  switch(n->type) {
    case T_INT_LIT:
    case T_KW_VERDADEIRO:
    case T_KW_FALSO:
      push(n->value);
      break;
    case VARIAVEIS:
      run_ast_var(n);
      break;
    case FUNCAO:
      run_ast_func(n);
      break;
    case RETORNE:
      run_ast_ret(n);
      break;
    case SE:
      run_ast_if(n);
      break;
    case ENQUANTO:
      run_ast_while(n);
      break;
    case PARA:
      run_ast_for(n);
      break;
    case BLOCO:
      run_ast_block(n);
      break;
    case '+':
      run_ast_plus(n);
      break;
    case '-':
      run_ast_minus(n);
      break;
    case '*':
      run_ast_mult(n);
      break;
    case '/':
      run_ast_div(n);
      break;
    case '%':
      run_ast_mod(n);
      break;
    case OP_UPLUS:
      run_ast_uplus(n);
      break;
    case OP_UMINUS:
      run_ast_uminus(n);
      break;
    case OP_REL_EQ:
      run_ast_eq(n);
      break;
    case OP_REL_INEQ:
      run_ast_ineq(n);
      break;
    case OP_REL_GT:      
      run_ast_gt(n);
      break;
    case OP_REL_GTEQ:
      run_ast_gteq(n);
      break;
    case OP_REL_LT:
      run_ast_lt(n);
      break;
    case OP_REL_LTEQ:
      run_ast_lteq(n);
      break;
    case OP_ATR:
      run_ast_attr(n);
      break;
    case OP_LOG_OU:
      run_ast_or(n);
      break;
    case OP_LOG_E:
      run_ast_and(n);
      break;
    case OP_LOG_NAO:
      run_ast_not(n);
      break;
  }
}


void run_ast(Node* n) {
  scope = NULL;
  rec_run_ast(n);
}
