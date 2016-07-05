import java.util.*;

/*
	Classe que contém as principais informaçoes
	relativas as variáveis
*/

public class VarsInfo{
	private int linhaDecl;
	private TiposRetorno tipo;
	private Object value;

	public VarsInfo(TiposRetorno tipo,int linhaDecl){
		this.tipo = tipo;
		this.linhaDecl = linhaDecl;
		this.value = 0;
	}

	/*
		Retorna o tipo da variável
	*/
	public TiposRetorno getTipo(){
		return tipo;
	}

	public Object getValue(){
		return value;
	}

	public void setValue(Object value){
		this.value = value;
	}

	/*
		Retorna a linha de declaraçao da variável
	*/
	public int getLinhaDecl(){
		return linhaDecl;
	}

}
