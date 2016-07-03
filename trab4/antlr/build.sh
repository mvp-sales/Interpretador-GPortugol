#!/bin/bash
export CLASSPATH=".:/usr/local/lib/antlr-4.5.3-complete.jar:$CLASSPATH"
alias antlr='java -jar /usr/local/lib/antlr-4.5.3-complete.jar'
antlr -no-listener -visitor GPortugol.g4
#javac Trab3.java GPortugol*.java AnalisadorSemantico.java ErroSemanticoException.java FunctionInfo.java VarsInfo.java TiposRetorno.java AST_Builder.java
javac *.java
