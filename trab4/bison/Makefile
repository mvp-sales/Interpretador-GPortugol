all: trab4

remove_prev: 
	rm scanner.c trab4 parser.c || true

parser.c: parser.y
	bison -Wall --defines=parser.h -o parser.c parser.y
	
scanner.c: scanner.l
	flex scanner.l
	
trab4: remove_prev scanner.c parser.c
	gcc -Wall parser.c scanner.c ast.c pilha.c runner.c typecheck.c funcoes.c variaveis.c -o trab4 -ly

