/*
	Classe que representa o acontecimento de um erro semantico
	Herda de RuntimeException para ser tratada somente no programa principal.
*/
public class ErroSemanticoException extends RuntimeException{
	public ErroSemanticoException(String msg){
		super(msg);
	}
}