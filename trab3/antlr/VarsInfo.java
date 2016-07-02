import java.util.*;

/*
	Classe que contém as principais informaçoes 
	relativas as variáveis
*/

public class VarsInfo{
	private int linhaDecl;
	private TiposRetorno tipo;

	public VarsInfo(TiposRetorno tipo,int linhaDecl){
		this.tipo = tipo;
		this.linhaDecl = linhaDecl;
	}

	/*
		Retorna o tipo da variável
	*/
	public TiposRetorno getTipo(){
		return tipo;
	}


	/*
		Retorna a linha de declaraçao da variável
	*/
	public int getLinhaDecl(){
		return linhaDecl;
	}

}
