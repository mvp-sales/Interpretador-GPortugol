import java.util.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;

public class AST_Builder extends GPortugolBaseVisitor<AbstractSyntaxTree>{
    AbstractSyntaxTree mainAST;
    Map<String,AbstractSyntaxTree> functionsAST = new HashMap<String,AbstractSyntaxTree>();

    public Map<String,AbstractSyntaxTree> getFunctionsAST(){
        return functionsAST;
    }


	@Override public AbstractSyntaxTree visitAlgoritmo(GPortugolParser.AlgoritmoContext ctx) {
        mainAST = visit(ctx.stm_block());
        for(GPortugolParser.Func_declsContext func : ctx.func_decls()){
            String nameFunc = func.IDENTIFICADOR().getText();
            AbstractSyntaxTree funcAST = visit(func.stm_block());
            functionsAST.put(nameFunc,funcAST);
        }
       return mainAST;
    }


	@Override public AbstractSyntaxTree visitStm_block(GPortugolParser.Stm_blockContext ctx) {
       AbstractSyntaxTree block = new AbstractSyntaxTree(AST_NodeType.BLOCK,null);
       for(GPortugolParser.Stm_listContext elem : ctx.stm_list()){
           block.insertChild(visit(elem));
       }
       return block;
	}


	@Override public AbstractSyntaxTree visitStm_list(GPortugolParser.Stm_listContext ctx) {
	    return visit(ctx.getChild(0));
	}


	@Override public AbstractSyntaxTree visitStm_ret(GPortugolParser.Stm_retContext ctx) {
	    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.RETURN,null);
        if(ctx.expr() != null){
	        node.insertChild(visit(ctx.expr()));
        }
	    return node;
	}


	@Override public AbstractSyntaxTree visitLvalue(GPortugolParser.LvalueContext ctx) {
	    return new AbstractSyntaxTree(AST_NodeType.VARIAVEL,ctx.IDENTIFICADOR().getSymbol());
	}


	@Override public AbstractSyntaxTree visitStm_attr(GPortugolParser.Stm_attrContext ctx) {
	    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.ATRIBUICAO,ctx.ATRIBUICAO().getSymbol());
	    node.insertChild(visit(ctx.lvalue()));
	    node.insertChild(visit(ctx.expr()));
	    return node;
	}


	@Override public AbstractSyntaxTree visitStm_se(GPortugolParser.Stm_seContext ctx) {
	    int i = 0;
	    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.IF,null);
	    node.insertChild(visit(ctx.expr()));

        AbstractSyntaxTree ifBlock = new AbstractSyntaxTree(AST_NodeType.BLOCK,null);
        node.insertChild(ifBlock);
	    for(i = 3; (ctx.getChild(i) instanceof GPortugolParser.Stm_listContext) ; i++){
	        ifBlock.insertChild(visit(ctx.getChild(i)));
	    }
	    if(ctx.getChild(i).getText().equals("senao")){
            AbstractSyntaxTree elseBlock = new AbstractSyntaxTree(AST_NodeType.BLOCK,null);
            node.insertChild(elseBlock);
	        for(int j = i+1; (ctx.getChild(j) instanceof GPortugolParser.Stm_listContext) ; j++){
    	        elseBlock.insertChild(visit(ctx.getChild(j)));
    	    }
	    }
	    return node;
	}



	@Override public AbstractSyntaxTree visitStm_enquanto(GPortugolParser.Stm_enquantoContext ctx) {
        AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.WHILE,null);
        node.insertChild(visit(ctx.expr()));
        AbstractSyntaxTree whileBlock = new AbstractSyntaxTree(AST_NodeType.BLOCK,null);
        for(GPortugolParser.Stm_listContext elem : ctx.stm_list()){
          whileBlock.insertChild(visit(elem));
        }
        node.insertChild(whileBlock);
        return node;
      }

	@Override public AbstractSyntaxTree visitStm_para(GPortugolParser.Stm_paraContext ctx) {
        AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.FOR,null);
        node.insertChild(visit(ctx.lvalue()));
        node.insertChild(visit(ctx.expr(0)));
        node.insertChild(visit(ctx.expr(1)));
        if(ctx.passo() != null){
            node.insertChild(visit(ctx.passo()));
        }
        AbstractSyntaxTree forBlock = new AbstractSyntaxTree(AST_NodeType.BLOCK,null);
        for(GPortugolParser.Stm_listContext elem : ctx.stm_list()){
            forBlock.insertChild(visit(elem));
        }
        node.insertChild(forBlock);
        return node;
    }

	@Override public AbstractSyntaxTree visitPasso(GPortugolParser.PassoContext ctx) {
         if(ctx.op != null){
             AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.OPERADOR,ctx.op);
             node.insertChild(new AbstractSyntaxTree(AST_NodeType.INTEIRO,ctx.INTEIRO().getSymbol()));
             return node;
         }
         return new AbstractSyntaxTree(AST_NodeType.INTEIRO,ctx.INTEIRO().getSymbol());
    }

	@Override public AbstractSyntaxTree visitExpr(GPortugolParser.ExprContext ctx) {
        if(ctx.termo() != null ){
          AbstractSyntaxTree node;
          if(ctx.opUnary != null){
            node = new AbstractSyntaxTree(AST_NodeType.OPERADOR,ctx.opUnary);
            node.insertChild(visit(ctx.termo()));
            return node;
          }
          node = visit(ctx.termo());
          return node;
        }
        AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.OPERADOR,(Token)ctx.getChild(1).getPayload());
        node.insertChild(visit(ctx.expr(0)));
        node.insertChild(visit(ctx.expr(1)));
        return node;
      }

	@Override public AbstractSyntaxTree visitTermo(GPortugolParser.TermoContext ctx) {
        if(ctx.expr() != null){
          return visit(ctx.expr());
        }
        return visit(ctx.getChild(0));
      }


	@Override public AbstractSyntaxTree visitFcall(GPortugolParser.FcallContext ctx) {
        AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.FUNCTION,ctx.IDENTIFICADOR().getSymbol());
        if(ctx.fargs() != null){
          for(GPortugolParser.ExprContext args : ctx.fargs().expr()){
            node.insertChild(visit(args));
          }
        }
        return node;
      }


	@Override public AbstractSyntaxTree visitLiteral(GPortugolParser.LiteralContext ctx) {
        //Token lit = (Token)ctx.getChild(0).getPayload();
        //AbstractSyntaxTree node;
        if(ctx.STRING() != null){
          return new AbstractSyntaxTree(AST_NodeType.LITERAL,ctx.STRING().getSymbol());
        }
        return new AbstractSyntaxTree(AST_NodeType.INTEIRO,ctx.INTEIRO().getSymbol());
        /*
        switch(lit.getType()){
          case GPortugolParser.LITERAL:
            node = new AbstractSyntaxTree(AST_NodeType.LITERAL,ctx.STRING().getSymbol());
          case GPortugolParser.INTEIRO:
            node = new AbstractSyntaxTree(AST_NodeType.INTEIRO,ctx.INTEIRO().getSymbol());
          case GPortugolParser.T_KW_FALSO:
            node = new AbstractSyntaxTree(AST_NodeType.LOGICO,ctx.T_KW_FALSO().getSymbol());
    			case GPortugolParser.T_KW_VERDADEIRO:
            node = new AbstractSyntaxTree(AST_NodeType.LOGICO,ctx.T_KW_VERDADEIRO().getSymbol());
          case GPortugolParser.CARACTERE:
            node = new AbstractSyntaxTree(AST_NodeType.CARACTERE,ctx.CARACTERE().getSymbol());
          case GPortugolParser.REAL:
            node = new AbstractSyntaxTree(AST_NodeType.REAL,ctx.REAL().getSymbol());
        }
        return node;
        */
     }

}
