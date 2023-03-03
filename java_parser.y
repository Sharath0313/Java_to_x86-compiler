%{
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm> 
#include <cstdio>
using namespace std;
void yyerror (char *s);
extern char* yytext;
extern int yylineno;
extern FILE *yyin;
int yylex();
%}

%union{
    int num;
    char id;
    char* str;
}

%start START
%token<str> INTEGRALTYPE FLOATINGPOINTTYPE BOOLEAN EXTENDS SUPER INTERFACE PUBLIC PROTECTED PRIVATE ABSTRACT
%token<str> STATIC FINAL DEFAULT CLASS IMPLEMENTS THROWS THIS SYNCHRONIZED
%token<str> VOID SWITCH CONTINUE FOR NEW IF DO BREAK THROW ELSE CASE INSTANCEOF RETURN TRANSIENT 
%token<str> CATCH TRY FINALLY VOLATILE NATIVE WHILE NULL_LITERAL BOOL_LITERAL ASSIGNMENT_OPERATOR
%token<str> INC DEC RELAND RELOR RELEQ RELNOTEQ SHIFT RELGL INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL TEXT_BLOCK
%token<str> IDENTIFIER PACKAGE IMPORT SEMICOLON DOT STAR OSB CSB OCB CCB ONB CNB COMMA COLON PLUS MINUS NEG NOT DIV MOD AND UP OR QM EQ

%%

START                   : CompilationUnit
                        ;                       

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
PackageDeclaration      : PACKAGE Name SEMICOLON
                        ;
ImportDeclaration       : SingleTypeImportDeclaration
                        | TypeImportOnDemandDeclaration
                        ;
SingleTypeImportDeclaration : IMPORT Name SEMICOLON           
                            ;
TypeImportOnDemandDeclaration   : IMPORT Name DOT STAR SEMICOLON
                                ;
TypeDeclaration         : CLassDeclaration
                        | InterfaceDeclaration
                        | SEMICOLON
                        ;

Literal                 : INT_LITERAL
                        | FLOAT_LITERAL
                        | BOOL_LITERAL
                        | CHAR_LITERAL
                        | STRING_LITERAL
                        | NULL_LITERAL
                        | TEXT_BLOCK
                        ;

Name                    : SingleName
                        | MultipleName
                        ;
SingleName              : IDENTIFIER
                        ;
MultipleName            : Name DOT IDENTIFIER
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
ArrayType               : PrimitiveType OSB CSB
                        | Name OSB CSB
                        | ArrayType OSB CSB
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
                        | InterfaceTypeList COMMA InterfaceType
                        ;
ClassBody               : OCB CCB
                        | OCB ClassBodyDeclarations CCB
                        ;
ClassBodyDeclarations   : ClassBodyDeclaration
                        | ClassBodyDeclarations ClassBodyDeclaration
                        ;
ClassBodyDeclaration    : ClassMemberDeclaration
                        | StaticInitializer
                        | ConstructorDeclaration
                        ;
ClassMemberDeclaration  : FieldDeclaration
                        | MethodDeclaration 
                        ;
FieldDeclaration        : Type VariableDeclarators SEMICOLON
                        | Modifiers Type VariableDeclarators SEMICOLON
                        ;
VariableDeclarators     : VariableDeclarator
                        | VariableDeclarators COMMA VariableDeclarator
                        ;
VariableDeclarator      : VariableDeclaratorId
                        | VariableDeclaratorId EQ VariableInitializer
                        ;
VariableDeclaratorId    : IDENTIFIER
                        | VariableDeclaratorId OSB CSB
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
                        | VOID MethodDeclarator
                        | Modifiers VOID MethodDeclarator
                        | VOID MethodDeclarator Throws
                        | Modifiers VOID MethodDeclarator Throws
                        ;
MethodDeclarator        : IDENTIFIER ONB CNB
                        | IDENTIFIER ONB FormalParameterList CNB
                        | MethodDeclarator OSB CSB
                        ;
FormalParameterList     : FormalParameter
                        | FormalParameterList COMMA FormalParameter
                        ;
FormalParameter         : Type VariableDeclaratorId
                        ;
Throws                  : THROWS ClassTypeList
                        ;
ClassTypeList           : ClassType
                        | ClassTypeList COMMA ClassType
                        ;
MethodBody              : Block 
                        | SEMICOLON
                        ;           
StaticInitializer       : STATIC Block
                        ;
ConstructorDeclaration  : ConstructorDeclarator ConstructorBody
                        | Modifiers ConstructorDeclarator ConstructorBody
                        | ConstructorDeclarator Throws ConstructorBody
                        | Modifiers ConstructorDeclarator Throws ConstructorBody
                        ;
ConstructorDeclarator   : SingleName ONB CNB
                        | SingleName ONB FormalParameterList CNB
                        ;
ConstructorBody         : OCB CCB
                        | OCB ExplicitConstructorInvocation CCB
                        | OCB BlockStatements CCB
                        | OCB ExplicitConstructorInvocation BlockStatements CCB
                        ;
ExplicitConstructorInvocation   : THIS ONB CNB SEMICOLON
                                | THIS ONB ArgumentList CNB SEMICOLON
                                | SUPER ONB CNB SEMICOLON
                                | SUPER ONB ArgumentList CNB SEMICOLON
                                ;

InterfaceDeclaration    : INTERFACE IDENTIFIER InterfaceBody
                        | Modifiers INTERFACE IDENTIFIER InterfaceBody
                        | INTERFACE IDENTIFIER ExtendsInterfaces InterfaceBody
                        | Modifiers INTERFACE IDENTIFIER ExtendsInterfaces InterfaceBody
                        ;
ExtendsInterfaces       : EXTENDS InterfaceType
                        | ExtendsInterfaces COMMA InterfaceType
                        ;
InterfaceBody           : OCB CCB
                        | OCB InterfaceMemberDeclarations CCB
                        ;
InterfaceMemberDeclarations : InterfaceMemberDeclaration 
                            | InterfaceMemberDeclarations InterfaceMemberDeclaration
                            ;
InterfaceMemberDeclaration  : ConstantDeclaration
                            | AbstractMethodDeclaration
                            ;
ConstantDeclaration     : FieldDeclaration
                        ;
AbstractMethodDeclaration   : MethodHeader SEMICOLON
                            ;

ArrayInitializer        : OCB CCB
                        | OCB VariableInitializers CCB
                        | OCB COMMA CCB
                        | OCB VariableInitializers COMMA CCB
                        ;
VariableInitializers    : VariableInitializer
                        | VariableInitializers COMMA VariableInitializer
                        ;

Block                   : OCB CCB
                        | OCB BlockStatements CCB
                        ;
BlockStatements         : BlockStatement
                        | BlockStatements BlockStatement
                        ;
BlockStatement          : LocalVariableDeclarationStatement
                        | Statement 
                        ;
LocalVariableDeclarationStatement   : LocalVariableDeclaration SEMICOLON
                                    ;
LocalVariableDeclaration    : Type VariableDeclarators
                            ;
Statement               : StatementWithoutTrailingSubstatement
                        | LabeledStatement
                        | IfThenStatement
                        | IfThenElseStatement
                        | WhileStatement
                        | ForStatement
                        ;
StatementNoShortIf      : StatementWithoutTrailingSubstatement
                        | LabeledStatementNoShortIf
                        | IfThenElseStatementNoShortIf
                        | WhileStatementNoShortIf
                        | ForStatementNoShortIf
                        ;
StatementWithoutTrailingSubstatement    : Block
                                        | EmptyStatement
                                        | ExpressionStatement
                                        | SwitchStatement
                                        | DoStatement 
                                        | BreakStatement
                                        | ContinueStatement
                                        | ReturnStatement
                                        | SynchronizedStatement
                                        | ThrowStatement
                                        | TryStatement
                                        ;
EmptyStatement          : SEMICOLON
                        ;
LabeledStatement        : IDENTIFIER COLON Statement
                        ;
LabeledStatementNoShortIf   : IDENTIFIER COLON StatementNoShortIf
                            ;
ExpressionStatement     : StatementExpression SEMICOLON
                        ;
StatementExpression     : Assignment 
                        | PreIncrementExpression
                        | PreDecrementExpression
                        | PostIncrementExpression
                        | PostDecrementExpression
                        | MethodInvocation
                        | ClassInstanceCreationExpression
                        ;
IfThenStatement         : IF ONB Expression CNB Statement
                        ;
IfThenElseStatement     : IF ONB Expression CNB StatementNoShortIf ELSE Statement
                        ;
IfThenElseStatementNoShortIf    : IF ONB Expression CNB StatementNoShortIf ELSE StatementNoShortIf
                                ;
SwitchStatement         : SWITCH ONB Expression CNB SwitchBlock
                        ;
SwitchBlock             : OCB CCB
                        | OCB SwitchLabels CCB
                        | OCB SwitchBlockStatementGroups CCB
                        | OCB SwitchBlockStatementGroups SwitchLabels CCB
                        ;
SwitchBlockStatementGroups  : SwitchBlockStatementGroup
                            | SwitchBlockStatementGroups SwitchBlockStatementGroup
                            ;
SwitchBlockStatementGroup   : SwitchLabels BlockStatements
                            ;
SwitchLabels            : SwitchLabel
                        | SwitchLabels SwitchLabel
                        ;
SwitchLabel             : CASE ConstantExpression COLON
                        | DEFAULT COLON
                        ;
WhileStatement          : WHILE ONB Expression CNB Statement
                        ;
WhileStatementNoShortIf : WHILE ONB Expression CNB StatementNoShortIf
                        ;
DoStatement             : DO Statement WHILE ONB Expression CNB SEMICOLON
                        ;
ForStatement            : FOR ONB SEMICOLON SEMICOLON   CNB Statement
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB Statement
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB Statement
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB Statement
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB Statement
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB Statement
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB Statement
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB Statement
                        ;
ForStatementNoShortIf   : FOR ONB SEMICOLON SEMICOLON   CNB StatementNoShortIf
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB StatementNoShortIf
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB StatementNoShortIf
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB StatementNoShortIf
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf
                        ;
ForInit                 : StatementExpressionList
                        | LocalVariableDeclaration
                        ;
ForUpdate               : StatementExpressionList
                        ;
StatementExpressionList : StatementExpression
                        | StatementExpressionList COMMA StatementExpression
                        ;
BreakStatement          : BREAK SEMICOLON
                        | BREAK IDENTIFIER  SEMICOLON
                        ;
ContinueStatement       : CONTINUE SEMICOLON
                        | CONTINUE IDENTIFIER SEMICOLON
                        ;
ReturnStatement         : RETURN SEMICOLON
                        | RETURN Expression SEMICOLON
                        ;
ThrowStatement          : THROW Expression  SEMICOLON
                        ;
SynchronizedStatement   : SYNCHRONIZED  ONB Expression CNB Block
                        ;
TryStatement            : TRY Block Catches
                        | TRY Block Finally 
                        | TRY Block Catches Finally 
                        ;
Catches                 : CatchClause
                        | Catches CatchClause
                        ;
CatchClause             : CATCH ONB FormalParameter CNB Block
                        ;
Finally                 : FINALLY Block
                        ;

Primary                 : PrimaryNoNewArray
                        | ArrayCreationExpression
                        ;
PrimaryNoNewArray       : Literal
                        | THIS
                        | ONB Expression CNB
                        | ClassInstanceCreationExpression
                        | FieldAccess
                        | MethodInvocation
                        | ArrayAccess
                        ;
ClassInstanceCreationExpression : NEW ClassType ONB CNB
                                | NEW ClassType ONB ArgumentList CNB
                                ;
ArgumentList            : Expression
                        | ArgumentList COMMA Expression
                        ;
ArrayCreationExpression : NEW PrimitiveType DimExprs 
                        | NEW PrimitiveType DimExprs Dims 
                        | NEW ClassOrInterfaceType DimExprs 
                        | NEW ClassOrInterfaceType DimExprs Dims
                        ;
DimExprs                : DimExpr
                        | DimExprs DimExpr
                        ;
DimExpr                 : OSB Expression CSB
                        ;
Dims                    : OSB CSB
                        | Dims OSB CSB
                        ;
FieldAccess             : Primary DOT IDENTIFIER
                        | SUPER DOT IDENTIFIER
                        ;
MethodInvocation        : Name ONB CNB
                        | Name ONB ArgumentList CNB
                        | Primary DOT IDENTIFIER ONB CNB
                        | Primary DOT IDENTIFIER ONB ArgumentList CNB
                        | SUPER DOT IDENTIFIER ONB CNB
                        | SUPER DOT IDENTIFIER ONB ArgumentList CNB
                        ;
ArrayAccess             : Name OSB Expression CSB
                        | PrimaryNoNewArray OSB Expression CSB
                        ;
PostfixExpression       : Primary   
                        | Name
                        | PostIncrementExpression
                        | PostDecrementExpression
                        ;
PostIncrementExpression : PostfixExpression INC
                        ;
PostDecrementExpression : PostfixExpression DEC
                        ;
UnaryExpression         : PreIncrementExpression
                        | PreDecrementExpression
                        | PLUS UnaryExpression
                        | MINUS UnaryExpression
                        | UnaryExpressionNotPlusMinus
                        ;
PreIncrementExpression  : INC UnaryExpression
                        ;
PreDecrementExpression  : DEC UnaryExpression
                        ;
UnaryExpressionNotPlusMinus : PostfixExpression
                            | NEG UnaryExpression
                            | NOT UnaryExpression
                            | CastExpression 
                            ;
CastExpression          : ONB PrimitiveType CNB UnaryExpression
                        | ONB PrimitiveType Dims CNB UnaryExpression
                        | ONB Expression CNB UnaryExpressionNotPlusMinus
                        | ONB Name Dims CNB UnaryExpressionNotPlusMinus
                        ;
MultiplicativeExpression    : UnaryExpression
                            | MultiplicativeExpression STAR UnaryExpression
                            | MultiplicativeExpression DIV UnaryExpression
                            | MultiplicativeExpression MOD UnaryExpression
                            ;
AdditiveExpression      : MultiplicativeExpression
                        | AdditiveExpression PLUS MultiplicativeExpression   
                        | AdditiveExpression MINUS MultiplicativeExpression
                        ;
ShiftExpression         : AdditiveExpression
                        | ShiftExpression SHIFT AdditiveExpression
                        ;
RelationalExpression    : ShiftExpression
                        | RelationalExpression RELGL ShiftExpression
                        | RelationalExpression INSTANCEOF ReferenceType
                        ;
EqualityExpression      : RelationalExpression
                        | EqualityExpression RELEQ RelationalExpression
                        | EqualityExpression RELNOTEQ RelationalExpression
                        ;
AndExpression           : EqualityExpression
                        | AndExpression AND EqualityExpression
                        ;
ExclusiveOrExpression   : AndExpression
                        | ExclusiveOrExpression UP AndExpression
                        ;
InclusiveOrExpression   : ExclusiveOrExpression
                        | InclusiveOrExpression OR ExclusiveOrExpression
                        ;
ConditionalAndExpression    : InclusiveOrExpression
                            | ConditionalAndExpression RELAND InclusiveOrExpression
                            ;
ConditionalOrExpression : ConditionalAndExpression
                        | ConditionalOrExpression RELOR ConditionalAndExpression
                        ;
ConditionalExpression   : ConditionalOrExpression
                        | ConditionalOrExpression QM Expression COLON ConditionalExpression
                        ;
AssignmentExpression    : ConditionalExpression
                        | Assignment
                        ;
Assignment              : LeftHandSide Assignment_Operators AssignmentExpression
                        ;
Assignment_Operators    : ASSIGNMENT_OPERATOR
                        | EQ
                        ;
LeftHandSide            : Name
                        | FieldAccess
                        | ArrayAccess
                        ;
Expression              : AssignmentExpression
                        ;
ConstantExpression      : Expression
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

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nFor the Token:%s\nIn Line number:%d\n", s, yytext, yylineno);} 
