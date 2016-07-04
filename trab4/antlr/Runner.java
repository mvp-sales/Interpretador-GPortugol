import java.util.*;

public class Runner{

	private Stack<Object> pilha = new Stack<Object>();
	private Stack<Map<String,VarsInfo>> scopeStack = new Stack<Map<String,VarsInfo>>();
	private Map<String,VarsInfo> varsTable;
	private Map<String,FunctionInfo> functionsTable;
	private Map<String,AbstractSyntaxTree> functionsAST;
	private boolean returnFlag;



	public Runner(Map<String,VarsInfo> varsTable,Map<String,FunctionInfo> functionsTable,Map<String,AbstractSyntaxTree> functionsAST){
		this.varsTable = varsTable;
		this.functionsTable = functionsTable;
		this.functionsAST = functionsAST;
		scopeStack.push(this.varsTable);
		returnFlag = false;
	}

	private void runArithmetics(String operator){
		Integer i1 = (Integer)pilha.pop();
		Integer i2 = (Integer)pilha.pop();
		switch(operator){
			case "+":
				pilha.push(i1+i2);
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

	private void runLogics(String operator){
		Boolean b1 = (Boolean)pilha.pop();
		Boolean b2 = (Boolean)pilha.pop();
		if(operator.equals("ou")){
			pilha.push(b1 || b2);
		}else{
			pilha.push(b1 && b2);
		}
	}

	private void runUnaryArithmetic(String symbol){
		Integer i = (Integer)pilha.pop();
		if(symbol.equals("+")){
			pilha.push(i);
		}else{
			pilha.push(-i);
		}
	}

	//It just works
	private void runEqualDiff(String operator){
		Object o1 = pilha.pop();
		Object o2 = pilha.pop();
		if(operator.equals("=")){
			pilha.push(o1.equals(o2));
		}else{
			pilha.push(!o1.equals(o2));
		}
	}

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

	private void imprima(AbstractSyntaxTree ast){
		String msg = "";
		//StringBuilder topoPilha;
		Integer i1;
		for(int i = 0; i < ast.getChildCount(); i++){
			/*try{
				i1 = (Integer)pilha.peek();
				pilha.pop();
				topoPilha = new StringBuilder(i1.toString());
			}catch(ClassCastException c){
				topoPilha = new StringBuilder(pilha.pop().toString());
				topoPilha.deleteCharAt(0);
				topoPilha.deleteCharAt(topoPilha.length()-1);
			}
			msg += topoPilha.toString();*/
			msg += pilha.pop().toString();
		}
		System.out.println(msg);
	}

	private void functionPrelude(int aridade){
		int i = 0;
		Map<String,VarsInfo> currentScope = scopeStack.peek();
		for(String name : currentScope.keySet()){
			VarsInfo v = currentScope.get(name);
			if(i < aridade){
				// Change this later
				v.setValue((Integer)pilha.pop());
				i++;
			}else{
				v.setValue(0);
			}
		}
	}

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

	private void runWhile(AbstractSyntaxTree ast){
		run(ast.getChild(0));
		Boolean exprValue = (Boolean)pilha.pop();
		while(exprValue.booleanValue()){
			run(ast.getChild(1));
			run(ast.getChild(0));
			exprValue = (Boolean)pilha.pop();
		}
	}

	private void runFor(AbstractSyntaxTree ast){
		Map<String,VarsInfo> currentScope = scopeStack.peek();
		VarsInfo variable = currentScope.get(ast.getChild(0).getPayload().getText());
		Integer var = variable.getValue();
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
				var = variable.getValue();
			}
		}else{
			for(var = start; var >= limit; var = var + passo){
				variable.setValue(var);
				run(ast.getChild(ast.getChildCount()-1));
				var = variable.getValue();
			}
		}
	}

	private void runFunction(AbstractSyntaxTree ast){
		for(int i = ast.getChildCount()-1; i >= 0; i--){
			run(ast.getChild(i));
		}
		String nameFunc = ast.getPayload().getText();
		if(nameFunc.equals("imprima")){
			imprima(ast);
		}else{
			scopeStack.push(functionsTable.get(nameFunc).getFunctionVarsTable());
			AbstractSyntaxTree funcAST = functionsAST.get(nameFunc);
			functionPrelude(ast.getChildCount());
			run(funcAST);
			returnFlag = false;
			scopeStack.pop();
		}
	}

	private void runAttr(AbstractSyntaxTree ast){
		Map<String,VarsInfo> currentScope = scopeStack.peek();
		run(ast.getChild(1));
		String nameVar = ast.getChild(0).getPayload().getText();
		Integer value = (Integer)pilha.pop();
		currentScope.get(nameVar).setValue(value);
	}

	public void run(AbstractSyntaxTree ast){

		switch(ast.getNodeType()){
			case BLOCK:
				for(int i = 0; i < ast.getChildCount(); i++){
					run(ast.getChild(i));
					if(returnFlag){
						return;
					}
				}
				break;
			case ATRIBUICAO:
				runAttr(ast);
				break;
			case VARIAVEL:
				Map<String,VarsInfo> currentScope = scopeStack.peek();
				pilha.push(currentScope.get(ast.getPayload().getText()).getValue());
				break;
			case INTEIRO:
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
				run(ast.getChild(0));
				returnFlag = true;
				return;
			case LITERAL:
				StringBuilder msg = new StringBuilder(ast.getPayload().getText());
				msg.deleteCharAt(0);
				msg.deleteCharAt(msg.length()-1);
				pilha.push(msg.toString());
				break;
			case FUNCTION:
				runFunction(ast);
				break;
			/*
			case LOGICO:
				if(ast.getPayload().getText().equals("verdadeiro")) pilha.push(true);//pilha.push(Boolean.TRUE);
				else pilha.push(false);//pilha.push(Boolean.FALSE);
				break;
			case CARACTERE:
				pilha.push(ast.getPayload().getText().charAt(1));
				break;
			case REAL:
				pilha.push(Double.parseDouble(ast.getPayload().getText()));
				break;
			*/
		}

	}
}
