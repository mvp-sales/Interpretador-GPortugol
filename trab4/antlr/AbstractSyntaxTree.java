import org.antlr.v4.runtime.Token;
import java.util.*;

public class AbstractSyntaxTree implements org.antlr.v4.runtime.tree.Tree{
    AbstractSyntaxTree parent = null;
    List<AbstractSyntaxTree> children = new LinkedList<AbstractSyntaxTree>();
    AST_NodeType nodeType;
    Token symbol;

    public AbstractSyntaxTree(AST_NodeType nodeType,Token symbol){
        this.nodeType = nodeType;
        this.symbol = symbol;
    }

    public AST_NodeType getNodeType(){
        return nodeType;
    }

    @Override
    public AbstractSyntaxTree getChild(int i){
        return children.get(i);
    }

    @Override
    public Token getPayload(){
        return symbol;
    }

    @Override
    public AbstractSyntaxTree getParent(){
        return parent;
    }

    public void setParent(AbstractSyntaxTree parent){
        this.parent = parent;
    }

    public String toStringTree(){
        for(AbstractSyntaxTree child : children){
            System.out.println(child.toStringTree());
        }
        return symbol.toString();
    }

    public int getChildCount(){
        return children.size();
    }

    public void insertChild(AbstractSyntaxTree node){
        /*if(children == null){
            children = new LinkedList<AbstractSyntaxTree>();
        }*/
        children.add(node);
        node.setParent(this);
    }
}
