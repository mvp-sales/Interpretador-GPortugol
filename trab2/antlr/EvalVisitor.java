import java.util.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.ParserRuleContext;

/*
	Visitação da Parse Tree:

		->	Visita o nó primário (algoritmo_goal), e faz uma visita aos filhos.
		->	Caso o filho seja regra, a função visitRule é chamada, a regra é impressa,
			os filhos desse filho são visitados, e assim por diante.
		->	Caso o filho seja um terminal, a função visitTerminal é chamada e ele imprime
			o nó.
		->	Ao voltar para o pai, a ligação entre o pai e o filho é impressa.
*/

public class EvalVisitor extends GPortugolDoisBaseVisitor<Integer>{
	/* 	
		Variável para marcar o número de nós visitados e o índice de cada nó
		visitado.
	*/
	private int numberNodes = 0;	

	/*
		Recebe um contexto de uma regra e o nome da regra, imprime tal contexto
		e visita os filhos de tal contexto, printando após a visita a ligaçao
		entre o contexto inicial e seus filhos.
	*/
	private Integer visitRule(ParserRuleContext ctx,String nameRule){
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\""+nameRule+"\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;
	}

	@Override
	public Integer visitTerminal(TerminalNode node){
		/*
			Adiciona backslashes a strings, para evitar erro durante o
			processamento do arquivo .dot para pdf
		*/
		if(node.getSymbol().getType() == GPortugolDoisLexer.STRING){
			String str = "\\"+node.getText();
			str = new StringBuilder(str).insert(str.length()-1,"\\").toString();
			System.out.println("node"+numberNodes+"[label=\""+str+"\"];");
		}
		else{
			System.out.println("node"+numberNodes+"[label=\""+node.getText()+"\"];");
		}
		return numberNodes++;
	}

	@Override 
	public Integer visitAlgoritmo(GPortugolDoisParser.AlgoritmoContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("digraph {\ngraph [ordering=\"out\"];");
		System.out.println("node"+thisNodeIndex+"[label=\"algoritmo_goal\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount()-1; i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		System.out.println("}");
		return 0;
	}

	@Override 
	public Integer visitDeclAlg(GPortugolDoisParser.DeclAlgContext ctx) {
		return visitRule(ctx,"algoritmo_decl");
	}

	@Override 
	public Integer visitVarDeclBlock(GPortugolDoisParser.VarDeclBlockContext ctx) { 
		return visitRule(ctx,"var_decl_block");
	}

	@Override 
	public Integer visitVarDecl(GPortugolDoisParser.VarDeclContext ctx) { 
		return visitRule(ctx,"var_decl");
	}

	@Override public Integer visitTp_primitivo(GPortugolDoisParser.Tp_primitivoContext ctx) {
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"tp_primitivo\"];");numberNodes++;
		int sonNodeIndex = visitChildren(ctx);
		System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		return thisNodeIndex; 
	}

	@Override public Integer visitTpMatriz(GPortugolDoisParser.TpMatrizContext ctx) { 
		return visitRule(ctx,"tp_matriz");
	}

	@Override public Integer visitTp_prim_pl(GPortugolDoisParser.Tp_prim_plContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"tp_primitivo_pl\"];");numberNodes++;
		int sonNodeIndex = visitChildren(ctx);
		System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		return thisNodeIndex; 
	}

	@Override public Integer visitStmBlock(GPortugolDoisParser.StmBlockContext ctx) { 
		return visitRule(ctx,"stm_block");
	}
	
	@Override public Integer visitStm_list(GPortugolDoisParser.Stm_listContext ctx) { 
		return visitRule(ctx,"stm_list");
	}
	
	@Override public Integer visitStmRet(GPortugolDoisParser.StmRetContext ctx) { 
		return visitRule(ctx,"stm_ret");
	}
	
	@Override public Integer visitLValue(GPortugolDoisParser.LValueContext ctx) { 
		return visitRule(ctx,"lvalue"); 
	}
	
	@Override public Integer visitStmAttr(GPortugolDoisParser.StmAttrContext ctx) { 
		return visitRule(ctx,"stm_attr");
	}
	
	@Override public Integer visitStmSe(GPortugolDoisParser.StmSeContext ctx) { 
		return visitRule(ctx,"stm_se");
	}
	
	@Override public Integer visitStmEnquanto(GPortugolDoisParser.StmEnquantoContext ctx) { 
		return visitRule(ctx,"stm_enquanto");
	}
	
	@Override public Integer visitStmPara(GPortugolDoisParser.StmParaContext ctx) { 
		return visitRule(ctx,"stm_para");
	}
	
	@Override public Integer visitStmPasso(GPortugolDoisParser.StmPassoContext ctx) { 
		return visitRule(ctx,"passo");
	}	
	
	@Override public Integer visitExpr(GPortugolDoisParser.ExprContext ctx) { 
		return visitRule(ctx,"expr");
	}
	
	@Override public Integer visitTermo(GPortugolDoisParser.TermoContext ctx) { 
		return visitRule(ctx,"termo"); 
	}
	
	@Override public Integer visitFCall(GPortugolDoisParser.FCallContext ctx) { 
		return visitRule(ctx,"fcall");
	}
	
	@Override public Integer visitFArgs(GPortugolDoisParser.FArgsContext ctx) { 
		return visitRule(ctx,"fargs");
	}
	
	@Override public Integer visitLiteral(GPortugolDoisParser.LiteralContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"literal\"];");numberNodes++;
		int sonNodeIndex = visitChildren(ctx);
		System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		return thisNodeIndex; 
	}
	
	@Override public Integer visitFuncDecls(GPortugolDoisParser.FuncDeclsContext ctx) { 
		return visitRule(ctx,"func_decls"); 
	}
	
	@Override public Integer visitFVarDecl(GPortugolDoisParser.FVarDeclContext ctx) { 
		return visitRule(ctx,"f_var_decl"); 
	}
	
	@Override public Integer visitFParams(GPortugolDoisParser.FParamsContext ctx) { 
		return visitRule(ctx,"f_params");
	}
	
	@Override public Integer visitFParam(GPortugolDoisParser.FParamContext ctx) { 
		return visitRule(ctx,"f_param");
	}
	
}