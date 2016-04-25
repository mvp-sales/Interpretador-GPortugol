/* Alunos:
    Gabriel Correa de Macena
    Marcus Vinicius Palassi Sales
*/

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

            /* Verifica o tipo de token e imprime na tela o
                tipo correspondente (utilizando a acao definida para cada
                tipo de token no arquivo .g4).
            */
			for (Token token : lexer.getAllTokens()) {}
		}catch(IOException e){
			System.out.println("Arquivo de entrada nao encontrado.");
			e.printStackTrace();
		}

	}
}