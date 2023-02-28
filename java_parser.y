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

%token<str> Identifier IntegralType FloatingPointType boolean extends super
%type<str> Type PrimitiveType ReferenceType Annotations NumericType ClassOrInterfaceType TypeVariable ArrayType ClassType InterfaceType Annotation TypeArguments AmbigousName Dims TypeParameter TypeBound TypeParameterModifier AdditionBounds TypeArgumentList TypeArgument WildCard WildCardBounds

%%

Type            : PrimitiveType
                | ReferenceType
                ;

PrimitiveType   : Annotations boolean
                | Annotations NumericType
                ;

NumericType     : IntegralType
                | FloatingPointType 
                ;

ReferenceType   : ClassOrInterfaceType
                | TypeVariable
                | ArrayType 
                ;

ClassOrInterfaceType    : ClassType
                        | InterfaceType
                        ;

ClassType       : Annotations Identifier
                | Annotations Identifier TypeArguments
                | AmbigousName '.' Annotations Identifier
                | AmbigousName '.' Annotations Identifier TypeArguments
                | ClassOrInterfaceType '.' Annotations Identifier 
                | ClassOrInterfaceType '.' Annotations Identifier TypeArguments
                ;

InterfaceType   : ClassType
                ;

TypeVariable    : Annotations Identifier
                ;

ArrayType       : PrimitiveType Dims
                | ClassOrInterfaceType Dims
                | TypeVariable Dims
                ;

Dims            : Annotations '[' ']'
                | Dims Annotations '[' ']'
                ;

TypeParameter   : Identifier
                | Identifier TypeBound
                | TypeParameterModifier TypeParameter
                ;

TypeParameterModifier   : Annotation
                        ;

TypeBound       : extends TypeVariable
                | extends ClassOrInterfaceType AdditionBounds
                ;

AdditionBounds  : '&' InterfaceType
                | AdditionBounds & InterfaceType
                | %empty
                ;

TypeArguments   : '<' TypeArgumentList '>'
                ;

TypeArgumentList    : TypeArgument
                    | TypeArgumentList ',' TypeArgument
                    ;

TypeArgument    : ReferenceType
                | WildCard 
                ;

WildCard        : Annotations '?'
                | Annotations WildCardBounds
                ;

WildCardBounds  : extends ReferenceType
                | super ReferenceType
                ;

Annotations     : %empty
                | Annotations Annotation    
                ;

AmbigousName    : Identifier
                | AmbigousName '.' Identifier
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
