all : 
	lex java_lexical_analyser.l
	bison -d -t -Wnone java_parser.y
	g++ lex.yy.c java_parser.tab.c -w -o myASTGenerator
	