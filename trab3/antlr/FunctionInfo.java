import java.util.*;

/*
	Classe que contém as principais informaçoes de cada funçao
*/

public class FunctionInfo{
	private int linhaDecl;
	private int aridade = 0;
	private TiposRetorno tipoRetorno;
	private Map<String,VarsInfo> varsTable = new LinkedHashMap<String,VarsInfo>();

	public FunctionInfo(TiposRetorno retorno,int linhaDecl){
		this.tipoRetorno = retorno;
		this.linhaDecl = linhaDecl;
	}

	public FunctionInfo(TiposRetorno retorno,int linhaDecl,int aridade){
		this.tipoRetorno = retorno;
		this.linhaDecl = linhaDecl;
		this.aridade = aridade;
	}


	/*
		Retorna a aridade da funçao
	*/
	public int getAridade(){
		return aridade;
	}


	/*
		Retorna o tipo do retorno da funçao
	*/
	public TiposRetorno getTipoRetorno(){
		return tipoRetorno;
	}

	/*
		Retorna a linha de declaracao da funçao
	*/
	public int getLinhaDecl(){
		return linhaDecl;
	}

	/*
		Retorna a linha de declaracao de uma variavel de uma funcao dado o nome da variável (parametro ou nao)
	*/
	public int getLinhaDeclVar(String nameVar){
		return varsTable.get(nameVar).getLinhaDecl();
	}


	/*
		Retorna a tabela de variáveis da funçao
	*/
	public Map<String,VarsInfo> getFunctionVarsTable(){
		return varsTable;
	}

	/*
		Dado o nome da variável, verifica se aquela funçao contém alguma variável com aquele nome
	*/
	public boolean containsVariable(String nameVar){
		if(varsTable.containsKey(nameVar)){
			return true;
		}
		return false;
	}

	/*
		Retorna uma lista contendo os parametros da funçao
	*/
	public List<VarsInfo> getParamList(){
		List<VarsInfo> paramList = new LinkedList<VarsInfo>();
		Iterator it = varsTable.entrySet().iterator();

		for(int i = 0; i < this.aridade; i++){
			Map.Entry entry = (Map.Entry)it.next();
			VarsInfo v = (VarsInfo)entry.getValue();
			paramList.add(v);
		}
		return paramList;
	}

	/*
		Insere uma variável na tabela de variáveis da funçao.
		Retorna true caso a insercao seja feita com sucesso
		Retorna false caso a variável ja exista na tabela
	*/
	public boolean insertVariable(String nameVar,VarsInfo var,boolean isParametro){
		if(!varsTable.containsKey(nameVar)){
			varsTable.put(nameVar,var);
			if(isParametro)
				aridade++;
			return true;
		}
		else{
			return false;
		}
	}
}
