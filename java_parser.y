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

ClassDeclaration    : NormalClassDeclaration
                    | EnumDeclaration
                    | RecordDeclaration
                    ;

NormalClassDeclaration  : class TypeIdentifier ClassBody
                        | class TypeIdentifier TypeParameters ClassBody
                        | class TypeIdentifier ClassExtends ClassBody
                        | class TypeIdentifier
                        | class TypeIdentifier ClassExtends ClassImplements ClassPermits ClassBody
                        | ClassModifier NormalClassDeclaration
                        ;

ClassModifier   : Annotation
                | public
                | protected
                | private
                | abstract
                | static
                | final
                | sealed
                | non-sealed
                | strictfp
                ;

TypeParameters  : '<' TypeParameterList '>'
                ;

TypeParameterList   : TypeParameter
                    | TypeParameterList TypeParameter
                    ;

ClassExtends    : extends ClassType
                ;

ClassImplements : implements ClassType
                ;

InterfaceTypeList   : InterfaceType
                    | InterfaceTypeList InterfaceType
                    ;

ClassPermits    : permits TypeName
                | ClassPermits TypeName
                ;

ClassBody   : '{'ClassBodyDeclarations'}'
            ;

ClassBodyDeclarations   :
                        | ClassBodyDeclarations ClassBodyDeclaration
                        ;

ClassBodyDeclaration    : ClassMemberDeclaration
                        | InstanceInitializer
                        | StaticInitializer
                        | ConstructorDeclaration
                        ;

ClassMemberDeclaration  : FieldDeclaration
                        | MethodDeclaration
                        | ClassDeclaration
                        | InterfaceDeclaration
                        | ';'
                        ;

FieldDeclaration    | UnannType VariableDeclarationList ';'
                    | FieldModifier FieldDeclaration
                    ;

FieldModifier   : Annotation
                | public
                | private
                | protected
                | static
                | final
                | transient
                | volatile
                ;

VariableDeclarationList : VariableDeclarator
                        | VariableDeclarationList VariableDeclarator
                        ;

VariableDeclarator  : VariableDeclaratorId
                    | VariableDeclaratorId '=' VariableInitializer
                    ;

VariableDeclaratorId    : Identifier
                        | Identifier Dims
                        ;

VariableInitializer : Expression
                    | ArrayInitializer
                    ;

UnannType   : UnannPrimitiveType
            | UnannReferenceType
            ;

UnannPrimitiveType  : NumericType
                    | boolean
                    ;

UnannReferenceType  : UnannClassOrInterfaceType
                    | UnannTypeVariable
                    | UnannArrayType
                    ;

UnannClassOrInterfaceType   : UnannClassType
                            | UnannInterfaceType
                            ;

UnannClassType  : TypeIdentifier
                | TypeIdentifier TypeArguments
                | PackageName '.' Annotation TypeIdentifier
                | PackageName '.' Annotation TypeIdentifier TypeArguments
                | UnannClassOrInterfaceType '.' Annotation TypeIdentifier
                | UnannClassOrInterfaceType '.' Annotation TypeIdentifier TypeArguments
                ;

UnannInterfaceType  : UnannClassType
                    ;

UnannTypeVariable   : TypeIdentifier
                    ;

UnannArrayType  : UnannPrimitiveType Dims
                | UnannClassOrInterfaceType Dims
                | UnannTypeVariable Dims
                ;

MethodDeclaration   : MethodHeader MethodBody
                    | MethodModifier MethodDeclaration
                    ;

MethodModifier  : Annotation
                | public
                | private
                | abstract
                | static
                | final
                | synchronized
                | native
                | strictfp
                ;

MethodHeader    : Result MethodDeclarator
                | Result MethodDeclarator throws
                | TypeParameters Annotation Result MethodDeclarator
                | TypeParameters Annotation Result MethodDeclarator throws
                ;

Result  : UnannType
        | void
        ;

MethodDeclarator    : Identifier '(' ')'
                    | Identifier '('ReceiverParameter ',' ')'
                    | Identifier '('ReceiverParameter ',' FormalParameterList ')'
                    | Identifier '(' ')' Dims
                    | Identifier '(' ReceiverParameter ',' ')' Dims
                    | Identifier '(' ReceiverParameter ',' FormalParameterList ')' Dims
                    | Identifier '(' FormalParameterList ')'
                    | Identifier '(' FormalParameterList ')' Dims
                    ;

ReceiverParameter   : Annotations UnannType this
                    | Annotations UnannTypeIdentifier '.' this
                    ;

Annotations : 
            | Annotations Annotation
            ;

FormalParameterList : FormalParameter
                    | FormalParameterList ',' FormalParameter
                    ;

FormalParameter : UnannType VariableDeclaratorId
                | UnannType Annotations '.' '.' '.' Identifier
                | VariableModifier FormalParameter
                ;

VariableModifier    : Annotation
                    | final
                    ;

throws  : throws ExceptionTypeList
        ;

ExceptionTypeList   : ExceptionType
                    | ExceptionTypeList ',' ExceptionType
                    ;

ExceptionType   : ClassType
                | TypeVariable
                ;

MethodBody  : Block ';'
            ;

InstanceInitializer : Block
                    ;

StaticInitializer   : static Block
                    ;

ConstructorDeclaration  : ConstructorDeclarator ConstructorBody
                        | ConstructorDeclarator throws ConstructorBody
                        | ConstructorModifier ConstructorDeclaration
                        ;

ConstructorModifier : Annotation
                    | public
                    | private
                    | protected
                    ;

ConstructorDeclarator   : SimpleTypeName '(' ')'
                        | TypeParameters SimpleTypeName '(' ')'
                        | SimpleTypeName '(' ReceiverParameter '.' ')'
                        | TypeParameters SimpleTypeName '(' ReceiverParameter ',' ')'
                        | SimpleTypeName '(' FormalParameterList ')'
                        | TypeParameters SimpleTypeName '(' FormalParameterList ')'
                        | TypeParameters SimpleTypeName '(' ReceiverParameter ',' FormalParameterList ')'
                        | SimpleTypeName '(' ReceiverParameter ',' FormalParameterList ')'
                        ;

ConstructorBody : '{' '}'
                | '{' ExplicitConstructorInvocation '}'
                | '{' BlockStatements '}'
                | '{' ExplicitConstructorInvocation BlockStatements '}'
                ;

SimpleTypeName  : TypeIdentifier
                ;

ExplicitConstructorInvocation   : this '(' ')' ';'
                                | this '(' ArgumentList ')' ';'
                                | TypeArguments this '(' ')' ';'
                                | TypeArguments this '(' ArgumentList ')' ';'
                                | super '(' ')' ';'
                                | ExpressionName '.' super '(' ')' ';'
                                | Primary '.' super '(' ')' ';'
                                ;

EnumDeclaration : enum TypeIdentifier EnumBody
                | enum TypeIdentifier ClassImplements EnumBody
                | ClassModifier EnumDeclaration
                ;

EnumBody    : '{' '}'
            | '{' EnumConstantList '}'
            | '{' EnumConstantList ',' '}'
            | '{' ',' '}'
            | '{' EnumConstantList EnumBodyDeclaration '}'
            | '{' EnumConstantList ',' EnumBodyDeclaration '}'
            | '{' ',' EnumBodyDeclaration '}'
            ;

EnumConstantList    : EnumConstant
                    | EnumConstantList ',' EnumConstant
                    ;

EnumConstant    : Identifier
                | Identifier '(' ')'
                | Identifier '(' ArgumentList ')'
                | Identifier ClassBody
                | Identifier '(' ')' ClassBody
                | Identifier '(' ArgumentList ')' ClassBody
                | EnumConstantModifier EnumConstant
                ;

EnumConstantModifier    : Annotation
                        ;

EnumBodyDeclaration : ';'
                    | EnumBodyDeclaration ClassBodyDeclaration
                    ;

RecordDeclaration   : record TypeIdentifier RecordHeader RecordBody
                    | record TypeIdentifier TypeParameter RecordHeader RecordBody
                    | record TypeIdentifier RecordHeader ClassImplements RecordBody
                    | record TypeIdentifier TypeParameter RecordHeader ClassImplements RecordBody
                    | ClassModifier RecordDeclaration
                    ;

RecordHeader    : '(' ')'
                | '(' RecordComponentList ')'
                ;

RecordComponentList : RecordComponent
                    | RecordComponentList ',' RecordComponent
                    ;

RecordComponent : UnannType Identifier
                | UnannType Annotations '.' '.' '.' Identifier
                | RecordComponentModifier
                ;

RecordComponentModifier : Annotations
                        ;

RecordBody  : '{' RecordBodyDeclarations '}'
            ;

RecordBodyDeclarations  : 
                        | RecordBodyDeclarations RecordBodyDeclaration
                        ;

RecordBodyDeclaration   : ClassBodyDeclaration
                        | CompactConstructorDeclaration
                        ;

CompactConstructorDeclaration   : SimpleTypeName ConstructorBody
                                | ConstructorModifier CompactConstructorDeclaration
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
