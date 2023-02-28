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

%token<str> Identifier IntegralType FloatingPointType boolean extends super interface public private protected abstract Static sealed non-sealed strictfp permits default
%type<str> Type PrimitiveType ReferenceType Annotations NumericType ClassOrInterfaceType TypeVariable ArrayType ClassType InterfaceType Annotation TypeArguments AmbigousName Dims TypeParameter TypeBound TypeParameterModifier AdditionBounds TypeArgumentList TypeArgument WildCard WildCardBounds
%type<str> InterfaceDeclaration NormalInterfaceDeclaration AnnotationInterfaceDeclaration InterfaceBody TypeParameters InterfaceExtends InterfacePermits InterfaceModifier InterfaceTypeList InterfaceMemberDeclaration InterfaceMemberDeclarations ConstantDeclaration InterfaceMethodDeclaration ClassDeclaration InterfaceDeclaration UnannType VariableDeclaratorList ConstantModifier MethodHeader MethodBody InterfaceMethodModifier AnnotationInterfaceBody AnnotationInterfaceMemberDeclarations AnnotationInterfaceMemberDeclaration AnnotationInterfaceElementDeclaration DefaultValue ElementValue NormalAnnotation MarkerAnnotation SingleElementAnnotation ElementValuePairList ElementValuePair ElementValueArrayInitializer ConditionalExpression ElementValueList

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

InterfaceDeclaration    : NormalInterfaceDeclaration
                        | AnnotationInterfaceDeclaration
                        ;

NormalInterfaceDeclaration  : interface Identifier InterfaceBody
                            | interface Identifier TypeParameters InterfaceBody
                            | interface Identifier InterfaceExtends InterfaceBody
                            | interface Identifier TypeParameters InterfaceExtends InterfaceBody
                            | interface Identifier InterfacePermits InterfaceBody
                            | interface Identifier TypeParameters InterfacePermits InterfaceBody
                            | interface Identifier InterfaceExtends InterfacePermits InterfaceBody
                            | interface Identifier TypeParameters InterfaceExtends InterfacePermits InterfaceBody
                            | InterfaceModifier NormalInterfaceDeclaration
                            ;

InterfaceModifier   : Annotation
                    | public
                    | private
                    | protected
                    | abstract
                    | Static
                    | sealed
                    | non-sealed
                    | strictfp
                    ;

InterfaceExtends    : extends InterfaceTypeList
                    ;

InterfacePermits    : permits AmbigousName
                    | InterfacePermits ',' AmbigousName
                    ;

InterfaceBody       : '{' InterfaceMemberDeclarations '}'
                    ;

InterfaceMemberDeclarations : %empty
                            | InterfaceMemberDeclarations InterfaceMemberDeclaration
                            ;

InterfaceMemberDeclaration  : ConstantDeclaration
                            | InterfaceMethodDeclaration
                            | ClassDeclaration
                            | InterfaceDeclaration
                            | ';'
                            ;

ConstantDeclaration     : UnannType VariableDeclaratorList ';'
                        | ConstantModifier ConstantDeclaration
                        ;

ConstantModifier        : Annotation 
                        | public
                        | Static
                        | final
                        ;

InterfaceMethodDeclaration  : MethodHeader MethodBody
                            | InterfaceMethodModifier InterfaceMethodDeclaration
                            ;

InterfaceMethodModifier     : Annotation
                            | public
                            | private
                            | abstract
                            | default
                            | Static
                            | strictfp
                            ;

AnnotationInterfaceDeclaration  : '@' interface Identifier AnnotationInterfaceBody
                                | InterfaceModifier AnnotationInterfaceDeclaration
                                ;

AnnotationInterfaceBody     : '{' AnnotationInterfaceMemberDeclarations '}'
                            ;

AnnotationInterfaceMemberDeclarations   : %empty
                                        | AnnotationInterfaceMemberDeclarations AnnotationInterfaceMemberDeclaration
                                        ;

AnnotationInterfaceMemberDeclaration    : ConstantDeclaration
                                        | ClassDeclaration
                                        | InterfaceDeclaration
                                        | AnnotationInterfaceElementDeclaration
                                        ;

AnnotationInterfaceElementDeclaration   : UnannType Identifier '(' ')' ';'
                                        | UnannType Identifier '(' ')' Dims ';'
                                        | UnannType Identifier '(' ')' DefaultValue ';'
                                        | UnannType Identifier '(' ')' Dims DefaultValue ';'
                                        | AnnotationInterfaceElementModifier AnnotationInterfaceElementDeclaration
                                        ;

AnnotationInterfaceElementModifier      : Annotation
                                        | public
                                        | abstract
                                        ;

DefaultValue        : default ElementValue
                    ;

Annotation          : NormalAnnotation
                    | MarkerAnnotation
                    | SingleElementAnnotation
                    ;

NormalAnnotation    : '@' AmbigousName '(' ')'
                    | '@' AmbigousName '(' ElementValuePairList ')'
                    ;

ElementValuePairList    : ElementValuePair
                        | ElementValuePairList ElementValuePair
                        ;

ElementValuePair    : Identifier = ElementValue
                    ;

ElementValue        : ConditionalExpression
                    | ElementValueArrayInitializer
                    | Annotation
                    ;

ElementValueArrayInitializer    : '{' '}'
                                | '{' ElementValueList '}'
                                | '{' ',' '}'
                                | '{' ElementValueList ',' '}'
                                ;

ElementValueList    : ElementValue
                    | ElementValueList ElementValue
                    ;

MarkerAnnotation    : '@' AmbigousName
                    ;

SingleElementAnnotation     : '@' AmbigousName '(' ElementValue ')'
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
