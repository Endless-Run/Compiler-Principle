parser : parser.tab.c lex.yy.c parser.tab.h def.h ast.c semantics.c objectCode.c
	gcc -o parser parser.tab.c lex.yy.c ast.c semantics.c objectCode.c -g 

parser.tab.c parser.tab.h : parser.y def.h
	bison -d -v parser.y

lex.yy.c : lex.l parser.tab.h def.h
	flex lex.l

run :
	./parser fibonacci.c

debug:
	gdb -q ./parser

clean :
	rm parser.tab.c lex.yy.c parser parser.tab.h	
