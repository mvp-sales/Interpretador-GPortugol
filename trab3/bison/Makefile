all: trab3

parser.c: parser.y
	bison -Wall --defines=parser.h -o parser.c parser.y
	
scanner.c: scanner.l
	flex scanner.l
	
trab3: scanner.c parser.c
	gcc -Wall parser.c scanner.c typecheck.c funcoes.c variaveis.c -o trab3 -ly

