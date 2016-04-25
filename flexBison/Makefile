all: trab1

lex.yy.c: trab1.l
	flex -o lex.yy.c trab1.l

trab1: lex.yy.c 
	gcc lex.yy.c -o trab1
