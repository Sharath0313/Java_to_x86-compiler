.PHONY : all
all : lex.yy.c java_parser.tab.c myASTGenerator

lex.yy.c: 
	lex java_lexical_analyser.l

java_parser.tab.c: 
	bison -d -t -Wnone java_parser.y

myASTGenerator:
	g++ lex.yy.c java_parser.tab.c -w -o myASTGenerator