#!/bin/bash

for i in {1..5}
do 
	#./trab1 < in/ex0$i.gpt > outFlex/ex0$i.out
	java Trab2 exemplos/in$i.gpt > outAntlr/in$i.dot
	dot -Tpdf outAntlr/in$i.dot -o outAntlr/in$i.pdf
done
