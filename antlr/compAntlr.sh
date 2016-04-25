#!/bin/bash
export CLASSPATH=".:/usr/local/lib/antlr-4.5.3-complete.jar:$CLASSPATH"
alias antlr='java -jar /usr/local/lib/antlr-4.5.3-complete.jar'
antlr GPortugol.g4
javac Trab1.java GPortugol.java