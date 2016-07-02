import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;

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
                    AST_Builder ast_builder = new AST_Builder();
                    AbstractSyntaxTree ast = ast_builder.visit(tree);
                    Runner runner = new Runner();
                    runner.run(ast);
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