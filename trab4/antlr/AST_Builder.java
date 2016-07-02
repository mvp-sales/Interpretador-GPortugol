import java.util.*;
import org.antlr.v4.runtime.tree.*;
import org.antlr.v4.runtime.ParserRuleContext;
import org.antlr.v4.runtime.Token;

public class AST_Builder extends GPortugolBaseVisitor<AbstractSyntaxTree>{
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitAlgoritmo(GPortugolParser.AlgoritmoContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitDeclaracao_algoritmo(GPortugolParser.Declaracao_algoritmoContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitVar_decl_block(GPortugolParser.Var_decl_blockContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitVar_decl(GPortugolParser.Var_declContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitTp_primitivo(GPortugolParser.Tp_primitivoContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitTp_matriz(GPortugolParser.Tp_matrizContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitTp_prim_pl(GPortugolParser.Tp_prim_plContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_block(GPortugolParser.Stm_blockContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_list(GPortugolParser.Stm_listContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_ret(GPortugolParser.Stm_retContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitLvalue(GPortugolParser.LvalueContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_attr(GPortugolParser.Stm_attrContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_se(GPortugolParser.Stm_seContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitStm_enquanto(GPortugolParser.Stm_enquantoContext ctx) { return visitChildren(ctx); }
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
	@Override public AbstractSyntaxTree visitExpr(GPortugolParser.ExprContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitTermo(GPortugolParser.TermoContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFcall(GPortugolParser.FcallContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFargs(GPortugolParser.FargsContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitLiteral(GPortugolParser.LiteralContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFunc_decls(GPortugolParser.Func_declsContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>The default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFvar_decl(GPortugolParser.Fvar_declContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFparams(GPortugolParser.FparamsContext ctx) { return visitChildren(ctx); }
	/**
	 * {@inheritDoc}
	 *
	 * <p>AbstractSyntaxTreehe default implementation returns the result of calling
	 * {@link #visitChildren} on {@code ctx}.</p>
	 */
	@Override public AbstractSyntaxTree visitFparam(GPortugolParser.FparamContext ctx) { return visitChildren(ctx); }
}