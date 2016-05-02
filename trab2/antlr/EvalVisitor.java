import java.util.*;
import org.antlr.v4.runtime.tree.*;

public class EvalVisitor extends GPortugolDoisBaseVisitor<Void>{
	private int numberNodes = 0;
	//private Stack<Map<Integer,String>> nodes;
	//private Map<Integer,String> nodes = new HashMap<Integer,String>();
	//Map<String,String>

	/*@Override 
	public String visitProg(GPortugolDoisParser.ProgContext ctx) { 
		return "digraph {\n" + visitChildren(ctx) + "}"; 
	}*/

	@Override 
	public Void visitAlgFuncDecl(GPortugolDoisParser.AlgFuncDeclContext ctx) { 
		System.out.println("digraph {\ngraph [ordering=\"out\"];");
		for(ParseTree children : ctx.children){
			//System.out.println(children.getText());

		}
		//System.out.println("node"+numberNodes+"[label=\"algoritmo_goal\"];\nnode"+numberNodes+" -> node0;");
		return null;
	}

	@Override 
	public Void visitAlgNoFuncDecl(GPortugolDoisParser.AlgNoFuncDeclContext ctx) { 
		System.out.println("digraph {\ngraph [ordering=\"out\"];");
		//visitChildren(ctx);
		//System.out.println("node"+numberNodes+"[label=\"algoritmo_goal\"];\nnode"+numberNodes+" -> node0;");
		//System.out.println(ctx.getText());
		//nodes.put(numberNodes+1,ctx.getChild(0).getText());
		for(ParseTree children : ctx.children){
			//System.out.println(children.getText());
			visit(children);
		}
		//visitChildren(ctx);
		return null;
	}
	@Override 
	public Void visitDeclAlg(GPortugolDoisParser.DeclAlgContext ctx) {
		System.out.println("node0[label=\"algoritmo_decl\"];");
		System.out.println("node1[label=\"algoritmo\"];\nnode0 -> node1;");
		System.out.println("node2[label=\""+ ctx.getChild(1).getText()+"\"];\nnode0 -> node2;");
		System.out.println("node3[label=\";\"];\nnode0 -> node3;");
		numberNodes += 4;
		return null; 
	}

	@Override 
	public Void visitVarDeclBlock(GPortugolDoisParser.VarDeclBlockContext ctx) { 
		System.out.println("node"+numberNodes+"[label=\"var_decl_block\"];");numberNodes++;
		System.out.println("node"+numberNodes+"[label=\"variaveis\"];"); numberNodes++;
		for(int i = 1; i < ctx.getChildCount() - 1; i++){
			visit(ctx.getChild(i));
		}
		System.out.println("node"+numberNodes+"[label=\"fim_variaveis\"];"); numberNodes++;
		return null; 
	}

	@Override 
	public Void visitVarDecl(GPortugolDoisParser.VarDeclContext ctx) { 
		System.out.println("node"+numberNodes+"[label=\""+ctx.getChild(0).getText()+"\"];");numberNodes++;
		for(int i = 1; !ctx.getChild(i).getText().equals(":"); i++){
			System.out.println("node"+numberNodes+"[label=\""+ctx.getChild(i).getText()+"\"];");numberNodes++;
		}
		System.out.println("node"+numberNodes+"[label=\":\"];");numberNodes++;
		visit(ctx.getChild(ctx.getChildCount()-1));
		return null;
	}

	@Override
	public Void visitTerminal(TerminalNode node){
		System.out.println(node.getText());
		return null;
	}

	/*@Override public T visitTpLogico(GPortugolDoisParser.TpLogicoContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpLiteral(GPortugolDoisParser.TpLiteralContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpCaractere(GPortugolDoisParser.TpCaractereContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpReal(GPortugolDoisParser.TpRealContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpInteiro(GPortugolDoisParser.TpInteiroContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpMatriz(GPortugolDoisParser.TpMatrizContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpPlLogicos(GPortugolDoisParser.TpPlLogicosContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpPlLiterais(GPortugolDoisParser.TpPlLiteraisContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpPlCaracteres(GPortugolDoisParser.TpPlCaracteresContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpPlReais(GPortugolDoisParser.TpPlReaisContext ctx) { return visitChildren(ctx); }

	@Override public T visitTpPlInteiros(GPortugolDoisParser.TpPlInteirosContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmBlock(GPortugolDoisParser.StmBlockContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmListPara(GPortugolDoisParser.StmListParaContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmListEnquanto(GPortugolDoisParser.StmListEnquantoContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmListSe(GPortugolDoisParser.StmListSeContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmListRet(GPortugolDoisParser.StmListRetContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmListFCall(GPortugolDoisParser.StmListFCallContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmListAttr(GPortugolDoisParser.StmListAttrContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmRet(GPortugolDoisParser.StmRetContext ctx) { return visitChildren(ctx); }

	@Override public T visitLValue(GPortugolDoisParser.LValueContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmAttr(GPortugolDoisParser.StmAttrContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmSe(GPortugolDoisParser.StmSeContext ctx) { return visitChildren(ctx); }
	*/
	@Override public Void visitStmEnquanto(GPortugolDoisParser.StmEnquantoContext ctx) { 
		System.out.println(ctx.getChildCount());
		//System.out.println(ctx.getText());
		/*for(int i = 0; i < ctx.getChildCount(); i++){
			System.out.println(ctx.getChild(i).getText());
		}*/
		return null; }

	/*@Override public T visitStmPara(GPortugolDoisParser.StmParaContext ctx) { return visitChildren(ctx); }

	@Override public T visitStmPasso(GPortugolDoisParser.StmPassoContext ctx) { return visitChildren(ctx); }

	@Override public T visitEqualDiff(GPortugolDoisParser.EqualDiffContext ctx) { return visitChildren(ctx); }

	@Override public T visitMulDivMod(GPortugolDoisParser.MulDivModContext ctx) { return visitChildren(ctx); }

	@Override public T visitAddSub(GPortugolDoisParser.AddSubContext ctx) { return visitChildren(ctx); }

	@Override public T visitBitwiseXOR(GPortugolDoisParser.BitwiseXORContext ctx) { return visitChildren(ctx); }

	@Override public T visitBitwiseOR(GPortugolDoisParser.BitwiseORContext ctx) { return visitChildren(ctx); }

	@Override public T visitLogicalAND(GPortugolDoisParser.LogicalANDContext ctx) { return visitChildren(ctx); }

	@Override public T visitUnaryTermo(GPortugolDoisParser.UnaryTermoContext ctx) { return visitChildren(ctx); }

	@Override public T visitBitwiseAND(GPortugolDoisParser.BitwiseANDContext ctx) { return visitChildren(ctx); }

	@Override public T visitBiggerLessEqual(GPortugolDoisParser.BiggerLessEqualContext ctx) { return visitChildren(ctx); }

	@Override public T visitLogicalOR(GPortugolDoisParser.LogicalORContext ctx) { return visitChildren(ctx); }

	@Override public T visitParenthesisExpr(GPortugolDoisParser.ParenthesisExprContext ctx) { return visitChildren(ctx); }

	@Override public T visitLiteralTerm(GPortugolDoisParser.LiteralTermContext ctx) { return visitChildren(ctx); }

	@Override public T visitLValueTerm(GPortugolDoisParser.LValueTermContext ctx) { return visitChildren(ctx); }

	@Override public T visitFCallTerm(GPortugolDoisParser.FCallTermContext ctx) { return visitChildren(ctx); }

	@Override public T visitFCall(GPortugolDoisParser.FCallContext ctx) { return visitChildren(ctx); }

	@Override public T visitFArgs(GPortugolDoisParser.FArgsContext ctx) { return visitChildren(ctx); }

	@Override public T visitLitFalso(GPortugolDoisParser.LitFalsoContext ctx) { return visitChildren(ctx); }

	@Override public T visitLitVerdadeiro(GPortugolDoisParser.LitVerdadeiroContext ctx) { return visitChildren(ctx); }

	@Override public T visitLitCaractere(GPortugolDoisParser.LitCaractereContext ctx) { return visitChildren(ctx); }

	@Override public T visitLitReal(GPortugolDoisParser.LitRealContext ctx) { return visitChildren(ctx); }

	@Override public T visitLitInteiro(GPortugolDoisParser.LitInteiroContext ctx) { return visitChildren(ctx); }

	@Override public T visitLitString(GPortugolDoisParser.LitStringContext ctx) { return visitChildren(ctx); }

	@Override public T visitFuncDecls(GPortugolDoisParser.FuncDeclsContext ctx) { return visitChildren(ctx); }

	@Override public T visitFVarDecl(GPortugolDoisParser.FVarDeclContext ctx) { return visitChildren(ctx); }

	@Override public T visitFParams(GPortugolDoisParser.FParamsContext ctx) { return visitChildren(ctx); }

	@Override public T visitFParam(GPortugolDoisParser.FParamContext ctx) { return visitChildren(ctx); }*/
	
}