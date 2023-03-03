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

%token<str> INTEGRALTYPE FLOATINGPOINTTYPE BOOLEAN EXTENDS SUPER INTERFACE PUBLIC PROTECTED PRIVATE ABSTRACT
%token<str> STATIC SEALED NON-SEALED STRICTFP PERMITS FINAL DEFAULT CLASS IMPLEMENTS THROWS THIS SYNCHRONIZED
%token<str> ENUM VOID SWITCH CONTINUE FOR NEW ASSERT IF DO BREAK THROW ELSE CASE INSTANCEOF RETURN TRANSIENT 
%token<str> CATCH TRY FINALLY VOLATILE NATIVE WHILE YIELD RECORD VAR KEYWORD NULL_LITERAL BOOL_LITERAL ASSIGNMENT_OPERATOR
%token<str> INC DEC SCOPE DOTS RELAND RELOR RELEQ RELNOTEQ SHIFT RELGL INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL TEXT_BLOCK
%token<str> IDENTIFIER OPERATOR SEPARATOR ERROR ARROW PACKAGE IMPORT
%%

CompilationUnit         : %empty
                        | PackageDeclaration 
                        | ImportDeclarations
                        | PackageDeclaration ImportDeclarations
                        | TypeDeclarations
                        | PackageDeclaration TypeDeclarations
                        | ImportDeclarations TypeDeclarations
                        | PackageDeclaration ImportDeclarations TypeDeclarations
                        ;
ImportDeclarations      : ImportDeclaration
                        | ImportDeclarations ImportDeclaration
                        ;
TypeDeclarations        : TypeDeclaration
                        | TypeDeclarations TypeDeclaration
                        ;
PackageDeclaration      : PACKAGE Name ';'
                        ;
ImportDeclaration       : SingleTypeImportDeclaration
                        | TypeImportOnDemandDeclaration
                        ;
SingleTypeImportDeclaration : IMPORT Name ';'
                            ;
TypeImportOnDemandDeclaration   : IMPORT Name '.' '*' ';'
                                ;
TypeDeclaration         : CLassDeclaration
                        | InterfaceDeclaration
                        ;
Literal                 : INT_LITERAL
                        | FLOAT_LITERAL
                        | BOOL_LITERAL
                        | CHAR_LITERAL
                        | STRING_LITERAL
                        | NULL_LITERAL
                        ;

Name                    : SingleName
                        | MultipleName
                        ;
SingleName              : IDENTIFIER
                        ;
MultipleName            : Name '.' IDENTIFIER
                        ;

Modifiers               : Modifier
                        | Modifiers Modifier
                        ;
Modifier                : PUBLIC
                        | PROTECTED
                        | PRIVATE
                        | STATIC
                        | ABSTRACT
                        | FINAL
                        | NATIVE
                        | SYNCHRONIZED
                        | TRANSIENT
                        | VOLATILE
                        ;

Type                    : PrimitiveType
                        | ReferenceType
                        ;
PrimitiveType           : NumericType
                        | BOOLEAN
                        ;
NumericType             : INTEGRALTYPE
                        | FLOATINGPOINTTYPE
                        ;
ReferenceType           : ClassOrInterfaceType
                        | ArrayType
                        ;
ClassOrInterfaceType    : Name
                        ;
ClassType               : ClassOrInterfaceType
                        ;
InterfaceType           : ClassOrInterfaceType
                        ;
ArrayType               : PrimitiveType '[' ']'
                        | Name '[' ']'
                        | ArrayType '[' ']'
                        ;

CLassDeclaration        : CLASS IDENTIFIER ClassBody
                        | Modifiers CLASS IDENTIFIER ClassBody
                        | CLASS IDENTIFIER Super ClassBody
                        | Modifiers CLASS IDENTIFIER Super ClassBody
                        | CLASS IDENTIFIER Interfaces ClassBody
                        | Modifiers CLASS IDENTIFIER Interfaces ClassBody
                        | CLASS IDENTIFIER Super Interfaces ClassBody
                        | Modifiers CLASS IDENTIFIER Super Interfaces ClassBody
                        ;
Super                   : EXTENDS ClassType
                        ;
Interfaces              : IMPLEMENTS InterfaceTypeList
                        ;
InterfaceTypeList       : InterfaceType
                        | InterfaceTypeList ',' InterfaceType
                        ;
ClassBody               : '{' '}'
                        | '{' ClassBodyDeclarations '}'
                        ;
ClassBodyDeclarations   : ClassBodyDeclaration
                        | ClassBodyDeclarations ClassBodyDeclaration
                        ;
ClassBodyDeclaration    : ClassMemberDeclaration
                        | StatiInitializer
                        | ConstructorDeclaration
                        ;
ClassMemberDeclaration  : FieldDeclaration
                        | MethodDeclaration 
                        ;
FieldDeclaration        : Type VariableDeclarators ';'
                        | Modifiers Type VariableDeclarators ';'
                        ;
VariableDeclarators     : VariableDeclarator
                        | VariableDeclarators ',' VariableDeclarator
                        ;
VariableDeclarator      : VariableDeclaratorId
                        | VariableDeclaratorId '=' VariableInitializer
VariableDeclaratorId    : IDENTIFIER
                        | VariableDeclaratorId '[' ']'
                        ;
VariableInitializer     : Expression
                        | ArrayInitializer
                        ;
MethodDeclaration       : MethodHeader MethodBody
                        ;
MethodHeader            : Type MethodDeclarator
                        | Modifiers Type MethodDeclarator
                        | Type MethodDeclarator Throws
                        | Modifiers Type MethodDeclarator Throws
                        | Void MethodDeclarator
                        | Modifiers Void MethodDeclarator
                        | Void MethodDeclarator Throws
                        | Modifiers Void MethodDeclarator Throws
                        ;
MethodDeclarator        : IDENTIFIER '(' ')'
                        | IDENTIFIER '(' FormalParameterList ')'
                        | MethodDeclarator '[' ']'
                        ;
FormalParameterList     : FormalParameter
                        | FormalParameterList ',' FormalParameter
                        ;
FormalParameter         : Type VariableDeclaratorId
                        ;
Throws                  : THROWS ClassTypeList
                        ;
ClassTypeList           : ClassType
                        | ClassTypeList ',' ClassType
                        ;
MethodBody              : Block 
                        | ';'
                        ;           
StatiInitializer        : STATIC Block
                        ;
ConstructorDeclaration  : ConstructorDeclarator ConstructorBody
                        | Modifier ConstructorDeclarator ConstructorBody
                        | ConstructorDeclarator Throws ConstructorBody
                        | Modifier ConstructorDeclarator Throws ConstructorBody
                        ;
ConstructorDeclarator   : SingleName '(' ')'
                        | SingleName '(' FormalParameterList ')'
                        ;
ConstructorBody         : '{' '}'
                        | '{' ExplicitConstructorInvocation '}'
                        | '{' BlockStatements '}'
                        | '{' ExplicitConstructorInvocation BlockStatements '}'
                        ;
ExplicitConstructorInvocation   : THIS '(' ')' ';'
                                | THIS '(' ArgumentList ')' ';'
                                | SUPER '(' ')' ';'
                                | SUPER '(' ArgumentList ')' ';'
                                ;

InterfaceDeclaration    : INTERFACE IDENTIFIER InterfaceBody
                        | Modifiers INTERFACE IDENTIFIER InterfaceBody
                        | INTERFACE IDENTIFIER ExtendsInterfaces InterfaceBody
                        | Modifiers INTERFACE IDENTIFIER ExtendsInterfaces InterfaceBody
                        ;
ExtendsInterfaces       : EXTENDS InterfaceType
                        | ExtendsInterfaces , InterfaceType
                        ;
InterfaceBody           : '{' '}'
                        | '{' InterfaceMemberDeclarations '}'
                        ;
InterfaceMemberDeclarations : InterfaceMemberDeclaration 
                            | InterfaceMemberDeclarations InterfaceMemberDeclaration
                            ;
InterfaceMemberDeclaration  : ConstantDeclaration
                            | AbstractMethodDeclaration
                            ;
ConstantDeclaration     : FieldDeclaration
                        ;
AbstractMethodDeclaration   : MethodHeader ';'
                            ;

ArrayInitializer        : '{' '}'
                        | '{' VariableInitializers '}'
                        ;
VariableInitializers    : VariableInitializer
                        | VariableInitializers ',' VariableInitializer
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
