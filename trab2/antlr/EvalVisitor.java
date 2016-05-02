import java.util.*;
import org.antlr.v4.runtime.tree.*;

public class EvalVisitor extends GPortugolDoisBaseVisitor<Integer>{
	private int numberNodes = 0;	

	@Override 
	public Integer visitAlgFuncDecl(GPortugolDoisParser.AlgFuncDeclContext ctx) { 
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
	public Integer visitAlgNoFuncDecl(GPortugolDoisParser.AlgNoFuncDeclContext ctx) { 
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
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"algoritmo_decl\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;
	}

	@Override 
	public Integer visitVarDeclBlock(GPortugolDoisParser.VarDeclBlockContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"var_decl_block\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}

	@Override 
	public Integer visitVarDecl(GPortugolDoisParser.VarDeclContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"var_decl\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}

	@Override
	public Integer visitTerminal(TerminalNode node){
		/*if(node.getSymbol().getType() == GPortugolDois.STRING){
			System.out.println("LOL ACHEI UMA STRING");
		}*/
		System.out.println("node"+numberNodes+"[label=\""+node.getText()+"\"];");
		return numberNodes++;
	}

	@Override public Integer visitTp_primitivo(GPortugolDoisParser.Tp_primitivoContext ctx) {
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"tp_primitivo\"];");numberNodes++;
		int sonNodeIndex = visit(ctx.getChild(0));
		System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		return thisNodeIndex; 
	}

	@Override public Integer visitTpMatriz(GPortugolDoisParser.TpMatrizContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"tp_matriz\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}

	@Override public Integer visitTp_prim_pl(GPortugolDoisParser.Tp_prim_plContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"tp_primitivo_pl\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}

	@Override public Integer visitStmBlock(GPortugolDoisParser.StmBlockContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_block\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitStm_list(GPortugolDoisParser.Stm_listContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_list\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitStmRet(GPortugolDoisParser.StmRetContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_ret\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitLValue(GPortugolDoisParser.LValueContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"lvalue\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitStmAttr(GPortugolDoisParser.StmAttrContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_attr\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitStmSe(GPortugolDoisParser.StmSeContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_se\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitStmEnquanto(GPortugolDoisParser.StmEnquantoContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_enquanto\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitStmPara(GPortugolDoisParser.StmParaContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"stm_para\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}
	
	@Override public Integer visitStmPasso(GPortugolDoisParser.StmPassoContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"passo\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}	
	
	@Override public Integer visitExpr(GPortugolDoisParser.ExprContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"expr\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitTermo(GPortugolDoisParser.TermoContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"termo\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}
	
	@Override public Integer visitFCall(GPortugolDoisParser.FCallContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"fCall\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}
	
	@Override public Integer visitFArgs(GPortugolDoisParser.FArgsContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"fArgs\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitLiteral(GPortugolDoisParser.LiteralContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"Literal\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitFuncDecls(GPortugolDoisParser.FuncDeclsContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"func_Decls\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}
	
	@Override public Integer visitFVarDecl(GPortugolDoisParser.FVarDeclContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"f_var_decl\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}
	
	@Override public Integer visitFParams(GPortugolDoisParser.FParamsContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"f_params\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex; 
	}
	
	@Override public Integer visitFParam(GPortugolDoisParser.FParamContext ctx) { 
		int thisNodeIndex = numberNodes;
		System.out.println("node"+thisNodeIndex+"[label=\"f_param\"];");numberNodes++;
		for(int i = 0; i < ctx.getChildCount(); i++){
			int sonNodeIndex = visit(ctx.getChild(i));
			System.out.println("node"+thisNodeIndex+" -> node"+sonNodeIndex+";");
		}
		return thisNodeIndex;  
	}
	
}