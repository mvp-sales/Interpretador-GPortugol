import org.antlr.v4.runtime.ANTLRFileStream;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.Lexer;
import org.antlr.v4.runtime.Token;
import java.io.*;

public class Trab1 {
	public static void main(String[] args) {
		scan(args[0]);
	}

	/* Funcao para fazer a analise lexica de
	um arquivo com codigo-fonte escrito na linguagem 
	G-Portugol.
	*/
	public static void scan(String text) {
		try{
			CharStream stream = new ANTLRFileStream(text);
			Lexer lexer = new GPortugol(stream);
			for (Token token : lexer.getAllTokens()) {
				/* Verifica o tipo de token e imprime na tela o
				tipo correspondente.
				*/
                /*switch(token.getType()){
                	case GPortugol.LOGICO:
                		System.out.println(token.getText()+" -> LOGICO");
                		break;
                	case GPortugol.OP_LOGICO:
                		System.out.println(token.getText()+" -> OPERADOR_LOGICO");
                		break;
                	case GPortugol.RESERVADA:
                		System.out.println(token.getText()+" -> PALAVRA_RESERVADA");
                		break;
                	case GPortugol.INTEIRO:
                		System.out.println(token.getText()+" -> INTEIRO");
                		break;
                	case GPortugol.REAL:
                		System.out.println(token.getText()+" -> REAL");
                		break;
                	case GPortugol.CARACTERE:
                		System.out.println(token.getText()+" -> CARACTERE");
                		break;
                	case GPortugol.STRING:
                		System.out.println(token.getText()+" -> LITERAL");
                		break;
                	case GPortugol.IDENTIFICADOR:
                		System.out.println(token.getText()+" -> IDENTIFICADOR");
                		break;
                	case GPortugol.OP_ARITMETICO:
                		System.out.println(token.getText()+" -> OPERADOR_ARITMETICO");
                		break;
                	case GPortugol.OP_RELACIONAL:
                		System.out.println(token.getText()+" -> OPERADOR_RELACIONAL");
                		break;
                	case GPortugol.ATRIBUICAO:
                		System.out.println(token.getText()+" -> ATRIBUICAO");
                		break;
                	case GPortugol.ESPECIAL:
                		System.out.println(token.getText()+" -> SIMBOLO_ESPECIAL");
                		break;
                    case GPortugol.UNKNOWN:
                        System.out.println(token.getText()+" -> DESCONHECIDO");
                        break;
            	}*/
	            
			}
		}catch(IOException e){
			System.out.println("Arquivo de entrada nao encontrado.");
			e.printStackTrace();
		}

	}
}