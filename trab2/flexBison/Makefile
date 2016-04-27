all: trab2

parser.c: parser.y
	bison -Wall --defines=parser.h -o parser.c parser.y
	
scanner.c: scanner.l
	flex scanner.l
	
trab2: scanner.c parser.c
	gcc -Wall parser.c scanner.c -o trab2 -ly

