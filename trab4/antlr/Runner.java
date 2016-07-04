import java.util.*;

public class Runner{

	//Stack<Integer> pilha = new Stack<Integer>();
	Stack<Object> pilha = new Stack<Object>();
	Stack<Map<String,VarsInfo>> scopeStack = new Stack<Map<String,VarsInfo>>();
	Map<String,VarsInfo> varsTable;
	Map<String,FunctionInfo> functionsTable;
	Map<String,AbstractSyntaxTree> functionsAST;


	public Runner(Map<String,VarsInfo> varsTable,Map<String,FunctionInfo> functionsTable,Map<String,AbstractSyntaxTree> functionsAST){
		this.varsTable = varsTable;
		this.functionsTable = functionsTable;
		this.functionsAST = functionsAST;
		scopeStack.push(this.varsTable);
	}

	private void evaluateExpression(AbstractSyntaxTree node){
		if(node.getChildCount() > 1){
			Integer i1 = (Integer)pilha.pop();
			Integer i2 = (Integer)pilha.pop();
			switch(node.getPayload().getText()){
				case "+":
					pilha.push(i1 + i2);
					break;
				case "-":
					pilha.push(i2-i1);
					break;
				case "*":
					pilha.push(i1 * i2);
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
				case "=":
					pilha.push(i2 == i1);
					break;
				//case "<>":
				default:
					pilha.push(i2 != i1);
					break;
				/*case "ou":
					pilha.push(i2 || i1):
					break;
				default:
					pilha.push(i2 && i1);
					break;*/
			}
		}else{
			Integer i = (Integer)pilha.pop();
			switch(node.getPayload().getText()){
				case "+":
					pilha.push(i);
					break;
				default:
					pilha.push(-i);
					break;
			}
		}
	}

	private void imprima(AbstractSyntaxTree ast){
		String msg = "";
		StringBuilder topoPilha;
		Integer i1;
		for(int i = 0; i < ast.getChildCount(); i++){
			try{
				i1 = (Integer)pilha.peek();
				pilha.pop();
				topoPilha = new StringBuilder(i1.toString());
			}catch(ClassCastException c){
				topoPilha = new StringBuilder(pilha.pop().toString());
				topoPilha.deleteCharAt(0);
				topoPilha.deleteCharAt(topoPilha.length()-1);
			}
			msg += topoPilha.toString();
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

	public void run(AbstractSyntaxTree ast){
		Map<String,VarsInfo> currentScope = scopeStack.peek();

		switch(ast.getNodeType()){
			case BLOCK:
				for(int i = 0; i < ast.getChildCount(); i++){
					run(ast.getChild(i));
				}
				break;
			case ATRIBUICAO:
				run(ast.getChild(1));
				String nameVar = ast.getChild(0).getPayload().getText();
				Integer value = (Integer)pilha.pop();
				currentScope.get(nameVar).setValue(value);
				break;
			case VARIAVEL:
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
				run(ast.getChild(0));
				Boolean exprValueIf = (Boolean)pilha.pop();
				if(exprValueIf.booleanValue()){
					run(ast.getChild(1));
				}else{
					if(ast.getChild(2) != null){
						run(ast.getChild(2));
					}
				}
				break;
			case WHILE:
				run(ast.getChild(0));
				Boolean exprValueWhile = (Boolean)pilha.pop();
				while(exprValueWhile.booleanValue()){
					run(ast.getChild(1));
					run(ast.getChild(0));
					exprValueWhile = (Boolean)pilha.pop();
				}
				break;
			case FOR:
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
				for(var = start; var != limit; var = var + passo){
					variable.setValue(var);
					run(ast.getChild(ast.getChildCount()-1));
					var = variable.getValue();
				}
				variable.setValue(var);
				run(ast.getChild(ast.getChildCount()-1));
				break;
			case RETURN:
				run(ast.getChild(0));
				return;
			case LITERAL:
				pilha.push(ast.getPayload().getText());
				break;
			case FUNCTION:
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
					scopeStack.pop();
				}
				break;
		}

	}
}
