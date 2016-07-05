import java.util.*;

public class Runner{

	/*
		O que foi implementado:
			-> Todo o básico
			-> Estrutura for
			-> Operações lógicas com outros tipos, exceto reais.
	*/

	private Stack<Object> pilha = new Stack<Object>();

	/*
		Pilha de escopos, guardando a tabela de variáveis que deve ser usada
		no escopo atual.
	*/
	private Stack<Map<String,VarsInfo>> scopeStack = new Stack<Map<String,VarsInfo>>();

	/*
		Tabelas de variáveis e de funções
	*/
	private Map<String,VarsInfo> varsTable;
	private Map<String,FunctionInfo> functionsTable;
	/*
		Tabela de ASTs das funções
	*/
	private Map<String,AbstractSyntaxTree> functionsAST;

	/*
		Flag que indica que um return aconteceu. Propósito de evitar que uma execução de
		função continue após tal return.
	*/
	private boolean returnFlag;



	public Runner(Map<String,VarsInfo> varsTable,Map<String,FunctionInfo> functionsTable,Map<String,AbstractSyntaxTree> functionsAST){
		this.varsTable = varsTable;
		this.functionsTable = functionsTable;
		this.functionsAST = functionsAST;
		scopeStack.push(this.varsTable);
		returnFlag = false;
	}

	/*
		Operações aritméticas e comparativas
	*/
	private void runArithmetics(String operator){
		Integer i1 = (Integer)pilha.pop();
		Integer i2 = (Integer)pilha.pop();
		switch(operator){
			case "+":
				pilha.push(i2 + i1);
				break;
			case "-":
				pilha.push(i2-i1);
				break;
			case "*":
				pilha.push(i2*i1);
				break;
			case "/":
				pilha.push(i2/i1);
				break;
			case "%":
				pilha.push(i2 % i1);
				break;
			case ">":
				pilha.push(i2 > i1);
				break;
			case ">=":
				pilha.push(i2 >= i1);
				break;
			case "<":
				pilha.push(i2 < i1);
				break;
			case "<=":
				pilha.push(i2 <= i1);
				break;
		}
	}

	/*
		Operações lógicas
	*/
	private void runLogics(String operator){
		Boolean b1 = (Boolean)pilha.pop();
		Boolean b2 = (Boolean)pilha.pop();
		if(operator.equals("ou")){
			pilha.push(b1 || b2);
		}else{
			pilha.push(b1 && b2);
		}
	}

	/*
		Operadores unários
	*/
	private void runUnaryArithmetic(String symbol){
		Integer i = (Integer)pilha.pop();
		if(symbol.equals("+")){
			pilha.push(i);
		}else{
			pilha.push(-i);
		}
	}

	/*
		Operadores de igualdade e diferença
	*/
	private void runEqualDiff(String operator){
		Object o1 = pilha.pop();
		Object o2 = pilha.pop();
		if(operator.equals("=")){
			pilha.push(o1.equals(o2));
		}else{
			pilha.push(!o1.equals(o2));
		}
	}

	/*
		Avaliador de expressões
	*/
	private void evaluateExpression(AbstractSyntaxTree node){
		if(node.getChildCount() > 1){
			switch(node.getPayload().getText()){
				case "+":
				case "-":
				case "*":
				case "/":
				case "%":
				case ">":
				case ">=":
				case "<":
				case "<=":
					runArithmetics(node.getPayload().getText());
					break;
				case "=":
				case "<>":
					runEqualDiff(node.getPayload().getText());
					break;
				case "ou":
				case "e":
					runLogics(node.getPayload().getText());
					break;
			}
		}else{
			switch(node.getPayload().getText()){
				case "+":
				case "-":
					runUnaryArithmetic(node.getPayload().getText());
					break;
				case "nao":
					Boolean b = (Boolean)pilha.pop();
					pilha.push(!b);
					break;
			}
		}
	}

	/*
		Função imprima
	*/
	private void imprima(AbstractSyntaxTree ast){
		String msg = "",tmp;
		Boolean b;
		for(int i = 0; i < ast.getChildCount(); i++){
			/*
				Tratamento para lógicos aparecerem como "verdadeiro" e "falso" em prints,
				ao invés de "true" e "false"
			*/
			try{
				b = (Boolean)pilha.peek();
				pilha.pop();
				if(b.booleanValue()) tmp = "verdadeiro";
				else tmp = "falso";
			}catch(ClassCastException c){
				tmp = pilha.pop().toString();
			}
			msg += tmp;
		}
		System.out.println(msg);
	}

	/*
		Prelúdio de uma função (atribuição dos valores dos argumentos nos parâmetros
		da função)
	*/
	private void functionPrelude(int aridade){
		int i = 0;
		Map<String,VarsInfo> currentScope = scopeStack.peek();
		for(String name : currentScope.keySet()){
			VarsInfo v = currentScope.get(name);
			if(i < aridade){
				v.setValue(pilha.pop());
				i++;
			}else{
				/*
					Atribuição de um valor padrão para as variáveis das funções
				*/
				v.setValue(0);
			}
		}
	}

	/*
		Bloco se-então
	*/
	private void runIf(AbstractSyntaxTree ast){
		run(ast.getChild(0));
		Boolean exprValue = (Boolean)pilha.pop();
		if(exprValue.booleanValue()){
			run(ast.getChild(1));
		}else{
			if(ast.getChildCount() == 3){
				run(ast.getChild(2));
			}
		}
	}

	/*
		Bloco enquanto
	*/
	private void runWhile(AbstractSyntaxTree ast){
		run(ast.getChild(0));
		Boolean exprValue = (Boolean)pilha.pop();
		while(exprValue.booleanValue()){
			run(ast.getChild(1));
			run(ast.getChild(0));
			exprValue = (Boolean)pilha.pop();
		}
	}

	/*
		Bloco para
	*/
	private void runFor(AbstractSyntaxTree ast){
		/*
			Escopo atual
		*/
		Map<String,VarsInfo> currentScope = scopeStack.peek();
		VarsInfo variable = currentScope.get(ast.getChild(0).getPayload().getText());

		Integer var = (Integer)variable.getValue();

		run(ast.getChild(1));
		Integer start = (Integer)pilha.pop();

		run(ast.getChild(2));
		Integer limit = (Integer)pilha.pop();

		Integer passo = new Integer(1);
		if(ast.getChildCount() > 4){
			run(ast.getChild(3));
			passo = (Integer)pilha.pop();
		}

		if(start <= limit){
			for(var = start; var <= limit; var = var + passo){
				variable.setValue(var);
				run(ast.getChild(ast.getChildCount()-1));
				var = (Integer)variable.getValue();
			}
		}else{
			for(var = start; var >= limit; var = var + passo){
				variable.setValue(var);
				run(ast.getChild(ast.getChildCount()-1));
				var = (Integer)variable.getValue();
			}
		}
	}

	/*
		Execução de funções
	*/
	private void runFunction(AbstractSyntaxTree ast){
		for(int i = ast.getChildCount()-1; i >= 0; i--){
			run(ast.getChild(i));
		}
		String nameFunc = ast.getPayload().getText();
		if(nameFunc.equals("imprima")){
			imprima(ast);
		}else{
			/*
				Inserção da tabela de variáveis da função na pilha de escopos
			*/
			scopeStack.push(functionsTable.get(nameFunc).getFunctionVarsTable());
			AbstractSyntaxTree funcAST = functionsAST.get(nameFunc);
			functionPrelude(ast.getChildCount());
			run(funcAST);
			returnFlag = false;
			/*
				Acabada a função, retire a tabela de variáveis dela
			*/
			scopeStack.pop();
		}
	}

	/*
		Comandos de atribuição
	*/
	private void runAttr(AbstractSyntaxTree ast){
		Map<String,VarsInfo> currentScope = scopeStack.peek();
		run(ast.getChild(1));
		String nameVar = ast.getChild(0).getPayload().getText();
		Object value = pilha.pop();
		currentScope.get(nameVar).setValue(value);
	}

	/*
		Função efetiva de run
	*/
	public void run(AbstractSyntaxTree ast){

		switch(ast.getNodeType()){
			case BLOCK:
				for(int i = 0; i < ast.getChildCount(); i++){
					run(ast.getChild(i));
					/*
						Caso algum nó tenha executado um return, não faça
						nada após esse ponto.
					*/
					if(returnFlag){
						return;
					}
				}
				break;
			case ATRIBUICAO:
				runAttr(ast);
				break;
			case VARIAVEL:
				/*
					Empurre o valor da variável no escopo atual para a pilha
				*/
				Map<String,VarsInfo> currentScope = scopeStack.peek();
				pilha.push(currentScope.get(ast.getPayload().getText()).getValue());
				break;
			case INTEIRO:
				/*
					Empurre o valor do inteiro para a pilha
				*/
				pilha.push(Integer.parseInt(ast.getPayload().getText()));
				break;
			case OPERADOR:
				run(ast.getChild(0));
				if(ast.getChildCount() > 1){
					run(ast.getChild(1));
				}
				evaluateExpression(ast);
				break;
			case IF:
				runIf(ast);
				break;
			case WHILE:
				runWhile(ast);
				break;
			case FOR:
				runFor(ast);
				break;
			case RETURN:
				if(ast.getChildCount() != 0){
					run(ast.getChild(0));
				}
				returnFlag = true;
				return;
			case LITERAL:
				/*
					Retirar as aspas da string
				*/
				StringBuilder msg = new StringBuilder(ast.getPayload().getText());
				msg.deleteCharAt(0);
				msg.deleteCharAt(msg.length()-1);
				pilha.push(msg.toString());
				break;
			case FUNCTION:
				runFunction(ast);
				break;
			case LOGICO:
				if(ast.getPayload().getText().equals("verdadeiro")) pilha.push(true);
				else pilha.push(false);
				break;
			case CARACTERE:
				pilha.push(ast.getPayload().getText().charAt(1));
				break;
		}

	}
}
