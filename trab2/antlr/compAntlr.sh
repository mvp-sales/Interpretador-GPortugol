#!/bin/bash
export CLASSPATH=".:/usr/local/lib/antlr-4.5.3-complete.jar:$CLASSPATH"
alias antlr='java -jar /usr/local/lib/antlr-4.5.3-complete.jar'
antlr -no-listener -visitor GPortugolDois.g4
javac Trab2.java GPortugolDois*.java EvalVisitor.java