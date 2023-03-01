%{
void yyerror (char *s);
extern char* yytext;
extern int yylineno;
extern FILE *yyin;
int yylex();
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm>
using namespace std;
%}

%union{
    int num;
    char id;
    char* str;
}

%token<str> 
%type<str> ArrayInitializer VariableInitializerList VariableInitializer

%%

ArrayInitializer    : 
                    | VariableInitializerList
                    | VariableInitializerList ArrayInitializer
                    | ArrayInitializer ArrayInitializer
                    ;

VariableInitializerList : VariableInitializer
                        | VariableInitializerList VariableInitializer
                        ;

%%                     


int main (int argc, char** argv) {

    if(argc!=2)
    {
        cout << "The syntax for execution is: program input_filename" << endl;
        return 0;
    }

    FILE *infile = fopen(argv[1], "r");
    if (!infile) {
        cout << "I can't open the file!" << endl;
        return -1;
    }
    yyin = infile;
    yyparse();
    fclose(infile);

    
	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nFor the Token: %s\nIn Line number:%d\n", s, yytext, yylineno);} 
