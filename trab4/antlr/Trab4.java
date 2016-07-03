import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;
import java.util.*;

public class Trab4 {
	public static void main(String[] args) {
        try{
            CharStream input = new ANTLRFileStream(args[0]);
            GPortugolLexer lexer = new GPortugolLexer(input);
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            GPortugolParser parser = new GPortugolParser(tokens);
            ParseTree tree = parser.algoritmo(); // parse

            /*
                Caso não haja erros no processo de parsing, a visita à arvore ocorrerá.
            */
            if(parser.getNumberOfSyntaxErrors() == 0){
                AnalisadorSemantico analyser = new AnalisadorSemantico();
                try{
                    analyser.visit(tree);
					Map<String,VarsInfo> varsTable = analyser.getVarsTable();
					Map<String,FunctionInfo> functionsTable = analyser.getFunctionsTable();
                    AST_Builder ast_builder = new AST_Builder();
                    AbstractSyntaxTree mainAST = ast_builder.visit(tree);
					Map<String,AbstractSyntaxTree> functionsAST = ast_builder.getFunctionsAST();
                    Runner runner = new Runner(varsTable,functionsTable,functionsAST);
                    runner.run(mainAST);
                }catch(ErroSemanticoException exc){
                    System.out.println(exc.getMessage());
                }
            }
            else{
                System.err.println("Erro de sintaxe!!!");
            }
        }
        catch(Exception exc){
            exc.printStackTrace();
        }

    }
}
