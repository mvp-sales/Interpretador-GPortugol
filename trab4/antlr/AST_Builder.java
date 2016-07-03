import java.util.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;

public class AST_Builder extends GPortugolBaseVisitor<AbstractSyntaxTree>{
    AbstractSyntaxTree mainAST;
    //Map<String,AbstractSyntaxTree>

	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitAlgoritmo(GPortugolParser.AlgoritmoContext ctx) {
        ast = visit(ctx.stm_block());
        /*for(GPortugolParser.Func_declsContext func : ctx.getChild(3)){

        }*/
       return ast;
    }
	@Override public AbstractSyntaxTree visitStm_block(GPortugolParser.Stm_blockContext ctx) {
	   if(ctx.stm_list().size() == 1){
	       return visitChildren(ctx);
	   }else if(ctx.stm_list().size() > 1){
	       AbstractSyntaxTree block = new AbstractSyntaxTree(AST_NodeType.BLOCK,null);
	       for(GPortugolParser.Stm_listContext elem : ctx.stm_list()){
	           block.insertChild(visit(elem));
	       }
	       return block;
	   }
	   return null;
	}
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_list(GPortugolParser.Stm_listContext ctx) {
	    return visit(ctx.getChild(0));
	}
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_ret(GPortugolParser.Stm_retContext ctx) {
	    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.RETURN,null);
	    node.insertChild(visit(ctx.expr()));
	    return node;
	}
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitLvalue(GPortugolParser.LvalueContext ctx) {
	    return new AbstractSyntaxTree(AST_NodeType.VARIAVEL,ctx.IDENTIFICADOR());
	}
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_attr(GPortugolParser.Stm_attrContext ctx) {
	    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.ATRIBUICAO,ctx.ATRIBUICAO());
	    node.insertChild(visit(ctx.lvalue()));
	    node.insertChild(visit(ctx.expr()));
	    return node;
	}
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_se(GPortugolParser.Stm_seContext ctx) {
	    int i = 0;
	    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.IF,null);
	    node.insertChild(visit(ctx.expr()));
	    //node.insertChild(visit(ctx.getChild(3)));
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
  /*@Override
  public AbstractSyntaxTree visitNormalIf(GPortugolParser.NormalIfContext ctx){
    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.IF,null);
    node.insertChild(visit(ctx.expr()));
    if(ctx.stm_list().size() > 1){

  }

    for(GPortugolParser.Stm_listContext elem : ctx.stm_list()){
      node.insertChild(visit(elem));
    }
    return node;
  }

  @Override
  public AbstractSyntaxTree visitIfElse(GPortugolParser.NormalIfContext ctx){
    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.IF,null);
    node.insertChild(visit(ctx.expr()));
    for(GPortugolParser.Stm_listContext elem : ctx.stm_list()){
      node.insertChild(visit(elem));
    }
    return node;
  }*/
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
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
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_para(GPortugolParser.Stm_paraContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitPasso(GPortugolParser.PassoContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
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
    node.insertChild(ctx.expr(0));
    node.insertChild(ctx.expr(1));
    return node;
  }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitTermo(GPortugolParser.TermoContext ctx) {
    if(ctx.expr() != null){
      return visit(ctx.expr());
    }
    return visit(ctx.getChild(0));
  }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFcall(GPortugolParser.FcallContext ctx) {
    AbstractSyntaxTree node = new AbstractSyntaxTree(AST_NodeType.FUNCTION,ctx.IDENTIFICADOR());
    if(ctx.fargs() != null){
      for(GPortugolParser.ExprContext args : ctx.fargs().expr()){
        node.insert(visit(args));
      }
    }
    return node;
  }


	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	//@Override public AbstractSyntaxTree visitFargs(GPortugolParser.FargsContext ctx) { return visitChildren(ctx); }


	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitLiteral(GPortugolParser.LiteralContext ctx) {
    if(ctx.STRING() != null){
      return new AbstractSyntaxTree(AST_NodeType.LITERAL,ctx.STRING());
    }
    return new AbstractSyntaxTree(AST_NodeType.INTEIRO,ctx.INTEIRO());
  }

	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	//@Override public AbstractSyntaxTree visitFunc_decls(GPortugolParser.Func_declsContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	//@Override public AbstractSyntaxTree visitFvar_decl(GPortugolParser.Fvar_declContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	//@Override public AbstractSyntaxTree visitFparams(GPortugolParser.FparamsContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	//@Override public AbstractSyntaxTree visitFparam(GPortugolParser.FparamContext ctx) { return visitChildren(ctx); }
}
