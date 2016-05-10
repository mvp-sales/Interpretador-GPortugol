import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
import java.io.*;

public class Trab2 {
	public static void main(String[] args) {
        try{
            CharStream input = new ANTLRFileStream(args[0]);
            GPortugolDoisLexer lexer = new GPortugolDoisLexer(input);
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            GPortugolDoisParser parser = new GPortugolDoisParser(tokens);
            ParseTree tree = parser.algoritmo(); // parse

            /*
                Caso não haja erros no processo de parsing, a visita à arvore ocorrerá.
            */
            if(parser.getNumberOfSyntaxErrors() == 0){
                EvalVisitor e = new EvalVisitor();
                e.visit(tree);
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