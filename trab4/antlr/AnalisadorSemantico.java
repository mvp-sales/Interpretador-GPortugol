import java.util.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;

/*
	CONVENCOES USADAS PARA DESENVOLVIMENTO DESTE ANALISADOR SEMANTICO

		-> Tratamento de matrizes foi desconsiderado, por razao de simplicidade (e por recomendaçao docente)
		-> Em estruturas condicionais, qualquer expressao eh valida (seguindo o manual)
		-> Na estrutura "enquanto", a mesma diretriz foi seguida.
		-> Tipos para os operadores:
			--> add, sub, mul, div -> real ou inteiro (operandos podem ser diferentes)
				---> retorna real ou inteiro
			--> >, >=, <, <= -> real, inteiro (operandos podem ser diferentes)
				---> retorna logico
			--> =, <> -> qualquer tipo (operandos soh podem ser diferentes quando forem numericos)
				---> retorna logico
			--> &, |, ^, ~, % (operadores binários e mod)-> inteiro 
				---> retorna inteiro
			--> e, ou, nao -> logico
				---> retorna logico

*/

public class AnalisadorSemantico extends GPortugolBaseVisitor<TiposRetorno>{


	/*
		Tabela de variaveis do bloco principal
	*/
	private Map<String,VarsInfo> varsTable = new HashMap<String,VarsInfo>();

	/*
		Tabela de funcoes
	*/
	private Map<String,FunctionInfo> functionTable = new HashMap<String,FunctionInfo>();

	/*
		Tabela de variaveis da funcao cujo bloco principal esteja
		sendo visitado
	*/
	private Map<String,VarsInfo> currentVisitedVarsTable;

	/*
		Funcao cujo bloco principal esteja sendo visitado
		(Usado principalmente para verificaçao de retorno de funçoes)
	*/
	private FunctionInfo currentVisitedFunction = null;

	/*
		A analise semantica se dá em duas fases. Na primeira, o analisador
		preenche as tabelas de variaveis e funçoes percorrendo o bloco de 
		declaraçoes de variaveis do bloco principal e percorrendo as declaraçoes
		de funçoes e seus blocos de variaveis. Ao final desta fase, a variavel fase1
		eh setada para true.
		A segunda fase eh a fase de visitaçao dos blocos principais (tanto do bloco
		principal quanto dos das funçoes). Para a diferenciaçao das tabelas de variáveis
		do bloco principal e do bloco principal de cada funçao, o hashmap 'currentVisitedVarsTable'
		é usado, sendo mudado para a tabela de variáveis de cada funçao visitada a cada
		iteracao do for da linha 88.
	*/
	private boolean fase1 = false;





	@Override
	public TiposRetorno visitAlgoritmo(GPortugolParser.AlgoritmoContext ctx){
		/*
			Insere na tabela de funcao as funcoes primitivas "leia" e "imprima"
		*/
		functionTable.put("leia",new FunctionInfo(TiposRetorno.INDEFINIDO,-1,0));
		functionTable.put("imprima",new FunctionInfo(TiposRetorno.VOID,-1,0));


		/*
			Fase 1 da análise semantica
		*/
		if(ctx.var_decl_block() != null){
			visit(ctx.var_decl_block());
		}

		if(ctx.func_decls() != null){
			for(GPortugolParser.Func_declsContext func : ctx.func_decls()){
				visit(func);
			}
		}

		fase1 = true;


		/*
			Fase 2 da análise semantica
		*/
		currentVisitedVarsTable = varsTable;
		visit(ctx.stm_block());

		for(GPortugolParser.Func_declsContext func : ctx.func_decls()){
			currentVisitedFunction = functionTable.get(func.IDENTIFICADOR().getText());
			currentVisitedVarsTable = currentVisitedFunction.getFunctionVarsTable();
			visit(func.stm_block());
		}
		return null;
	}





	/*
		Visita o bloco de variáveis e preenche a tabela de variáveis
	*/
	@Override
	public TiposRetorno visitVar_decl(GPortugolParser.Var_declContext ctx) {

		List<String> nomeVariaveis = new LinkedList<String>();
		int linhaDecl = ctx.getStart().getLine();

		for(int i = 0; ctx.IDENTIFICADOR(i) != null ; i++){
			String nome = ctx.IDENTIFICADOR(i).getText();
			if(varsTable.containsKey(nome) || nomeVariaveis.contains(nome)){
				int linhaVarDecl = (varsTable.containsKey(nome)) ? varsTable.get(nome).getLinhaDecl() : linhaDecl;
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": variável \'"+nome+"\' já foi declarada na linha "+linhaVarDecl+".");
			}
			nomeVariaveis.add(nome);
		}

		if(ctx.tp_primitivo() != null){
			String tipo_str = ctx.tp_primitivo().getStart().getText();
			TiposRetorno tipo = TiposRetorno.valueOf(tipo_str.toUpperCase());
			for(String nomeVar : nomeVariaveis){
				varsTable.put(nomeVar,new VarsInfo(tipo,linhaDecl));
			}
		}
		return null;
	}





	@Override 
	public TiposRetorno visitLvalue(GPortugolParser.LvalueContext ctx) {

		int linhaDecl = ctx.getStart().getLine();
		String varName = ctx.IDENTIFICADOR().getText();

		if(!currentVisitedVarsTable.containsKey(varName)){
			throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
						": variável \'"+varName+"\' não foi declarada.");
		}

		VarsInfo var = currentVisitedVarsTable.get(varName);
		return var.getTipo();
	}






	@Override 
	public TiposRetorno visitStm_attr(GPortugolParser.Stm_attrContext ctx) {

		int linhaDecl = ctx.getStart().getLine();

		TiposRetorno tipo_lvalue = visit(ctx.lvalue());
		TiposRetorno tipo_expr = visit(ctx.expr());


		/*
			Caso de diferença entre os tipos do statement de atribuicao
		*/
		if(tipo_lvalue != tipo_expr){
			/*
				Apenas eh permitido o lvalue ser do tipo real e a expressao retornar o tipo inteiro (coerçao ocorre)
			*/
			if(!(tipo_lvalue == TiposRetorno.REAL && tipo_expr == TiposRetorno.INTEIRO)){
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
					": expressão com tipos de dados incompatíveis.");
			}
		}
		return null;
	}






	/*
		Operacao que retorna um booleano caso os tipos dos valores no bloco "para" nao sejam numericos
	*/
	private boolean verificaTipoStmPara(TiposRetorno lvalue,TiposRetorno expr1,TiposRetorno expr2){
		if(		(lvalue != TiposRetorno.INTEIRO && lvalue != TiposRetorno.REAL)
			||	(expr1 != TiposRetorno.INTEIRO && expr1 != TiposRetorno.REAL)
			||	(expr2 != TiposRetorno.INTEIRO && expr2 != TiposRetorno.REAL)){
			return false;
		}
		if(lvalue != expr1){
			if(!(lvalue == TiposRetorno.REAL && expr1 == TiposRetorno.INTEIRO)){
				return false;
			}
		}
		return true;
	}

	@Override 
	public TiposRetorno visitStm_para(GPortugolParser.Stm_paraContext ctx) {
		int linhaDecl = ctx.getStart().getLine();
		TiposRetorno tipo_lvalue = visit(ctx.lvalue());
		TiposRetorno tipo_expr1 = visit(ctx.expr(0));
		TiposRetorno tipo_expr2 = visit(ctx.expr(1));
		boolean verificacaoTipos = verificaTipoStmPara(tipo_lvalue,tipo_expr1,tipo_expr2);

		if(verificacaoTipos){
			for(GPortugolParser.Stm_listContext p : ctx.stm_list()){
				visit(p);
			}
		}else{
			throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
				": expressão com tipos de dados incompatíveis.");
		}
		return null;
	}






	/*
		Verificacao de expressoes
	*/
	@Override 
	public TiposRetorno visitExpr(GPortugolParser.ExprContext ctx){

		int linhaDecl = ctx.getStart().getLine();
		TiposRetorno ret;

		if(ctx.getChildCount() <= 2){

			ret = visit(ctx.termo());

			if(ctx.getChildCount() == 2){
				Token op = (Token)ctx.getChild(0).getPayload();
				switch(op.getType()){

					/*
						Expressoes unárias que apenas aceitam tipos numéricos
						Retorno : inteiro ou real
					*/
					case GPortugolParser.OP_ADD:
					case GPortugolParser.OP_SUB:
						if(ret != TiposRetorno.INTEIRO || ret != TiposRetorno.REAL){
							throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
								": expressão com tipos de dados incompatíveis.");
						}
						break;
					/*
						Expressao unária que apenas aceita tipo inteiro
						Retorno : inteiro
					*/
					case GPortugolParser.NAO_BINARIO:
						if(ret != TiposRetorno.INTEIRO){
							throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
								": expressão com tipos de dados incompatíveis.");
						}
						break;
					/*
						Expressao unária que apenas aceita tipo logico
						Retorno : logico
					*/
					default:
						if(ret != TiposRetorno.LOGICO){
							throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
								": expressão com tipos de dados incompatíveis.");
						}
						break;
				}
			}
			return ret;
		}
		else{
			Token op = (Token)ctx.getChild(1).getPayload();
			TiposRetorno t1 = visit(ctx.expr(0));
			TiposRetorno t2 = visit(ctx.expr(1));
			switch(op.getType()){
				/*
					Expressoes que apenas aceitam tipos numéricos
					Retorno : inteiro ou real
				*/
				case GPortugolParser.OP_ADD:
				case GPortugolParser.OP_SUB:
				case GPortugolParser.OP_DIV:
				case GPortugolParser.OP_MUL:
					if(t1 != TiposRetorno.INTEIRO && t1 != TiposRetorno.REAL &&
							t2 != TiposRetorno.REAL && t2 != TiposRetorno.INTEIRO){
								throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
									": expressão com tipos de dados incompatíveis.");
					}
					if(t1 != t2) ret=TiposRetorno.REAL;
					else ret = t1;
					break;
				/*
					Expressoes relacionais (aceitam somente tipos numericos)
					Retorno : logico
				*/
				case GPortugolParser.OP_MORE:
				case GPortugolParser.OP_MORE_EQUAL:
				case GPortugolParser.OP_LESS:
				case GPortugolParser.OP_LESS_EQUAL:
					if(t1 != TiposRetorno.INTEIRO && t1 != TiposRetorno.REAL &&
							t2 != TiposRetorno.REAL && t2 != TiposRetorno.INTEIRO){
								throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
									": expressão com tipos de dados incompatíveis.");
					}
					ret = TiposRetorno.LOGICO;
					break;
					
				/*
					Expressao que aceita qualquer tipo de dados
					Retorno : logico
				*/
				case GPortugolParser.OP_EQUAL:
				case GPortugolParser.OP_DIFF:
					if(t1 != t2){
						if(t1 != TiposRetorno.INTEIRO && t1 != TiposRetorno.REAL &&
								t2 != TiposRetorno.REAL && t2 != TiposRetorno.INTEIRO){
									throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
										": expressão com tipos de dados incompatíveis.");
						}
					}
					ret = TiposRetorno.LOGICO;
					break;
				/*
					Expressoes que apenas aceitam o tipo inteiro
					Retorno : inteiro
				*/
				case GPortugolParser.OP_MOD:
				case GPortugolParser.E_BINARIO:
				case GPortugolParser.XOR_BINARIO:
				case GPortugolParser.OU_BINARIO:
					if(t1 != TiposRetorno.INTEIRO || t2 != TiposRetorno.INTEIRO){
						throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
							": expressão com tipos de dados incompatíveis.");
					}
					ret = TiposRetorno.INTEIRO;
					break;
				/*
					Expressoes que apenas aceitam o tipo logico
					Retorno : logico
				*/
				default:
					if(t1 != TiposRetorno.LOGICO || t2 != TiposRetorno.LOGICO){
						throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
							": expressão com tipos de dados incompatíveis.");
					}
					ret = TiposRetorno.LOGICO;
					break;

			}
		}
		return ret;
	}





	@Override 
	public TiposRetorno visitTermo(GPortugolParser.TermoContext ctx) {
		if(ctx.expr() == null){
			return visit(ctx.getChild(0));
		}
		return visit(ctx.expr());
	}






	/*
		Contexto para verificacao de retornos de funcoes
	*/
	@Override 
	public TiposRetorno visitStm_ret(GPortugolParser.Stm_retContext ctx){
		int linhaDecl = ctx.getStart().getLine();
		if(ctx.expr() != null){
			TiposRetorno ret = visit(ctx.expr());
			if(currentVisitedFunction != null){
				TiposRetorno retFunc = currentVisitedFunction.getTipoRetorno();
				if(retFunc != ret){
					if(!(retFunc == TiposRetorno.REAL && ret == TiposRetorno.INTEIRO) ){
						throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
							": expressão com tipos de dados incompatíveis.");
					}
				}
				return retFunc;
			}
		}
		return TiposRetorno.VOID;
	}






	/*
		Verificaçao de chamada de funcao
	*/
	@Override 
	public TiposRetorno visitFcall(GPortugolParser.FcallContext ctx) {
		int linhaDecl = ctx.getStart().getLine();
		String nomeFunc = ctx.IDENTIFICADOR().getText();
		if(!functionTable.containsKey(nomeFunc)){
			throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
				": função \'"+nomeFunc+"\' não foi declarada.");
		}
		/*
			Verificacao da funcao primitiva imprima
		*/
		if(nomeFunc.equals("imprima")){
			if(ctx.fargs() == null){
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": função \'"
						+nomeFunc+"\' foi chamada com 0"+
						" argumentos mas declarada para ter ao menos um parametro.");
			}
			return TiposRetorno.VOID;
		}
		/*
			Verificacao da funcao primitiva leia
		*/
		else if(nomeFunc.equals("leia")){
			FunctionInfo func = functionTable.get(nomeFunc);
			if(ctx.fargs() != null){
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": função \'"
						+nomeFunc+"\' foi chamada com "+ctx.fargs().expr().size()+
						" argumentos mas declarada com 0 parametros.");
			}


			/*
				Bloco de código para que a funcao leia retorne o tipo do lvalue no contexto de atribuicao
			*/

			ParserRuleContext parent = ctx.getParent();
			if(!(parent instanceof GPortugolParser.TermoContext)){
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": uso incorreto"
						+" da funcao primitiva \'"+nomeFunc+"\'.");
			}

			for(int i = 0; i < 2; i++){
				parent = parent.getParent();
				if(i == 0){
					if(parent.getChildCount() != 1){
						throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": uso incorreto"
						+" da funcao primitiva \'"+nomeFunc+"\'.");
					}
				}
				else if(i == 1){
					if(!(parent instanceof GPortugolParser.Stm_attrContext)){
						throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": uso incorreto"
						+" da funcao primitiva \'"+nomeFunc+"\'.");
					}
				}
			}

			GPortugolParser.Stm_attrContext p = (GPortugolParser.Stm_attrContext)parent;
			return visit(p.lvalue());
		}
		else{
			/*
				Tratamento de funcoes definidas pelo programador
			*/
			FunctionInfo func = functionTable.get(nomeFunc);
			int fargsNumber = (ctx.fargs() == null) ? 0 : ctx.fargs().expr().size();
			if(fargsNumber != func.getAridade()){
					throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+": função \'"
						+nomeFunc+"\' foi chamada com "+fargsNumber+
						" argumentos mas declarada com "+func.getAridade()+" parametros.");
			}
			if(fargsNumber > 0){
				visitFunctionArgs(ctx.fargs(),func);
			}
			return func.getTipoRetorno();
		}
	}





	/*
		Funcao para verificar se os argumentos fornecidos para uma funcao estao corretos
	*/
	public void visitFunctionArgs(GPortugolParser.FargsContext ctx,FunctionInfo func){
		int linhaDecl = ctx.getStart().getLine();
		List<VarsInfo> funcParams = func.getParamList();
		for(int i = 0; i < ctx.expr().size(); i++){
			if(visit(ctx.expr(i)) != funcParams.get(i).getTipo()){
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
					": expressão com tipos de dados incompatíveis.");
			}
		}
	}





	@Override 
	public TiposRetorno visitLiteral(GPortugolParser.LiteralContext ctx) {
		TiposRetorno ret;
		Token lit = (Token)ctx.getChild(0).getPayload();
		switch(lit.getType()){
			case GPortugolParser.T_KW_FALSO:
			case GPortugolParser.T_KW_VERDADEIRO:
				ret = TiposRetorno.LOGICO; break;

			case GPortugolParser.CARACTERE:
				ret = TiposRetorno.CARACTERE; break;

			case GPortugolParser.REAL:
				ret = TiposRetorno.REAL; break;

			case GPortugolParser.INTEIRO:
				ret = TiposRetorno.INTEIRO; break;

			default:
				ret = TiposRetorno.LITERAL; break;
		}
		return ret;
	}





	/*
		Visitacao da declaracao de funcao, preenchendo a tabela de funcao
		ou visitando o bloco principal
	*/
	@Override 
	public TiposRetorno visitFunc_decls(GPortugolParser.Func_declsContext ctx) {
		/*
			Caso a fase 1 nao esteja completa, insira essa funcao na tabela com seus dados
		*/
		if(!fase1){
			int linhaDecl = ctx.getStart().getLine();
			String nomeFunc = ctx.IDENTIFICADOR().getText();
			TiposRetorno tipoFunc;
			if(ctx.tp_primitivo() != null){
				String tipo_str = ctx.tp_primitivo().getStart().getText();
				tipoFunc = TiposRetorno.valueOf(tipo_str.toUpperCase());
			}
			else{
				tipoFunc = TiposRetorno.VOID;
			}
			FunctionInfo func = new FunctionInfo(tipoFunc,linhaDecl);
			if(ctx.fparams() != null){
				visitFunctionParams(ctx.fparams(),func);
			}
			visitFunctionVarDecl(ctx.fvar_decl(),func);
			if(functionTable.containsKey(nomeFunc)){
				int linhaFuncDecl = functionTable.get(nomeFunc).getLinhaDecl();
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
					": função \'"+nomeFunc+"\' já foi declarada na linha "
						+linhaFuncDecl+".");
			}
			functionTable.put(nomeFunc,func);
		}else{
			/*
				Caso a fase 1 esteja terminada, faça a verificacao semantica do 
				bloco principal da funcao
			*/
			visit(ctx.stm_block());
		}
		return null;
	}

	public void visitFunctionParams(GPortugolParser.FparamsContext ctx,FunctionInfo func){
		for(GPortugolParser.FparamContext fparam : ctx.fparam()){
			visitFunctionParam(fparam,func);
		}
	}

	/*
		Insere os parametros da funcao na tabela de variáveis da mesma
	*/
	public void visitFunctionParam(GPortugolParser.FparamContext ctx,FunctionInfo func){
		int linhaDecl = ctx.getStart().getLine();
		String nomeVar = ctx.IDENTIFICADOR().getText();

		if(ctx.tp_primitivo() != null){
			String tipo_str = ctx.tp_primitivo().getStart().getText();
			TiposRetorno tipo = TiposRetorno.valueOf(tipo_str.toUpperCase());
			boolean flag = func.insertVariable(nomeVar,new VarsInfo(tipo,linhaDecl),true);
			if(!flag){
				int linhaVarDecl = func.getLinhaDeclVar(nomeVar);
				throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
					": parametro \'"+nomeVar+"\' já foi declarada na linha "+linhaVarDecl+".");
			}
		}
	}


	/*
		Insere as variaveis de uma funcao na tabela de variaveis
	*/
	public void visitFunctionVarDecl(GPortugolParser.Fvar_declContext ctx,FunctionInfo func){
		for(GPortugolParser.Var_declContext varDecl : ctx.var_decl()){
			List<String> nomeVariaveis = new LinkedList<String>();
			int linhaDecl = varDecl.getStart().getLine();
			for(int i = 0; varDecl.IDENTIFICADOR(i) != null ; i++){
				String nome = varDecl.IDENTIFICADOR(i).getText();
				if(func.containsVariable(nome) || nomeVariaveis.contains(nome)){
					int linhaVarDecl = (func.containsVariable(nome)) ? func.getLinhaDeclVar(nome) : linhaDecl;
					throw new ErroSemanticoException("Erro semantico na linha "+linhaDecl+
						": variável \'"+nome+"\' já foi declarada na linha "+linhaVarDecl+".");
				}
				nomeVariaveis.add(nome);
			}

			if(varDecl.tp_primitivo() != null){
				String tipo_str = varDecl.tp_primitivo().getStart().getText();
				TiposRetorno tipo = TiposRetorno.valueOf(tipo_str.toUpperCase());
				for(String nomeVar : nomeVariaveis){
					func.insertVariable(nomeVar,new VarsInfo(tipo,linhaDecl),false);
				}
			}
		}
	}

}
