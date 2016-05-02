import org.antlr.v4.runtime.*;
import org.antlr.v4.runtime.tree.*;
/*import org.antlr.v4.runtime.ANTLRFileStream;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Token;*/
import java.io.*;

public class Trab2 {
	public static void main(String[] args) {
        try{
		/*String inputFile = null;
        if ( args.length>0 ) inputFile = args[0];
        InputStream is = System.in;
        if ( inputFile!=null ) is = new FileInputStream(inputFile);
        ANTLRInputStream input = new ANTLRInputStream(is);*/
            CharStream input = new ANTLRFileStream(args[0]);
            GPortugolDoisLexer lexer = new GPortugolDoisLexer(input);
            CommonTokenStream tokens = new CommonTokenStream(lexer);
            GPortugolDoisParser parser = new GPortugolDoisParser(tokens);
            ParseTree tree = parser.algoritmo(); // parse

            EvalVisitor e = new EvalVisitor();
            e.visit(tree);
        }
        catch(IOException e){
            e.printStackTrace();
        }

    }
}