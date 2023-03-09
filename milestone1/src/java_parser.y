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
ofstream outfile;
int node = 0;
%}

%union{
    int num;
    char id;
    char* str;
}

%start START 
%token<str> INTEGRALTYPE FLOATINGPOINTTYPE BOOL_LITERAL ASSIGNMENT_OPERATOR SHIFT RELGL INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL TEXT_BLOCK IDENTIFIER NULL_LITERAL
%token<str> BOOLEAN EXTENDS SUPER INTERFACE PUBLIC PROTECTED PRIVATE ABSTRACT
%token<str> STATIC FINAL DEFAULT CLASS IMPLEMENTS THROWS THIS SYNCHRONIZED 
%token<str> VOID SWITCH CONTINUE FOR NEW IF DO BREAK THROW ELSE CASE INSTANCEOF RETURN TRANSIENT 
%token<str> CATCH TRY FINALLY VOLATILE NATIVE WHILE   
%token<str> INC DEC RELAND RELOR RELEQ RELNOTEQ 
%token<str> PACKAGE IMPORT SEMICOLON DOT STAR OSB CSB OCB CCB ONB CNB COMMA COLON PLUS MINUS NEG NOT DIV MOD AND UP OR QM EQ
%type<num>  START CompilationUnit ImportDeclarations TypeDeclarations PackageDeclaration ImportDeclaration SingleTypeImportDeclaration  
%type<num>  TypeImportOnDemandDeclaration TypeDeclaration  Name SingleName MultipleName Modifiers Modifier Type PrimitiveType ReferenceType
%type<num>  NumericType ClassOrInterfaceType ClassType InterfaceType ArrayType ClassDeclaration Super Interfaces InterfaceTypeList ClassBody ClassBodyDeclarations
%type<num>  ClassBodyDeclaration ClassMemberDeclaration FieldDeclaration VariableDeclarators VariableDeclarator VariableDeclaratorId VariableInitializer
%type<num>  MethodDeclaration MethodHeader MethodDeclarator FormalParameterList FormalParameter Throws ClassTypeList MethodBody StaticInitializer
%type<num>  ConstructorDeclaration ConstructorDeclarator ConstructorBody ExplicitConstructorInvocation InterfaceDeclaration ExtendsInterfaces InterfaceBody
%type<num>  InterfaceMemberDeclarations InterfaceMemberDeclaration ConstantDeclaration AbstractMethodDeclaration ArrayInitializer VariableInitializers Block
%type<num>  BlockStatements BlockStatement LocalVariableDeclarationStatement LocalVariableDeclaration Statement StatementNoShortIf StatementWithoutTrailingSubstatement
%type<num>  EmptyStatement LabeledStatement LabeledStatementNoShortIf ExpressionStatement StatementExpression IfThenStatement IfThenElseStatement IfThenElseStatementNoShortIf
%type<num>  SwitchStatement SwitchBlock SwitchBlockStatementGroups SwitchBlockStatementGroup SwitchLabels SwitchLabel WhileStatement WhileStatementNoShortIf DoStatement
%type<num>  ForStatement ForStatementNoShortIf ForInit ForUpdate StatementExpressionList BreakStatement ContinueStatement ReturnStatement ThrowStatement SynchronizedStatement
%type<num>  TryStatement Catches CatchClause Finally Primary PrimaryNoNewArray ClassInstanceCreationExpression ArgumentList ArrayCreationExpression DimExprs DimExpr Dims FieldAccess
%type<num>  MethodInvocation ArrayAccess PostfixExpression PostIncrementExpression PostDecrementExpression UnaryExpression PreIncrementExpression PreDecrementExpression Literal
%type<num>  UnaryExpressionNotPlusMinus CastExpression MultiplicativeExpression AdditiveExpression ShiftExpression RelationalExpression EqualityExpression AndExpression
%type<num>  ExclusiveOrExpression InclusiveOrExpression ConditionalAndExpression ConditionalOrExpression ConditionalExpression AssignmentExpression Assignment LeftHandSide Assignment_Operators Expression ConstantExpression

%%

START                   : CompilationUnit
                        ;                       

CompilationUnit         : %empty                                {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                }
                        | PackageDeclaration                    {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;}
                        | ImportDeclarations                    {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;}
                        | PackageDeclaration ImportDeclarations {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                                outfile << $$ << "->" << $2 << ";" << endl;}
                        | TypeDeclarations                      {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;}
                        | PackageDeclaration TypeDeclarations   {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                                outfile << $$ << "->" << $2 << ";" << endl;}
                        | ImportDeclarations TypeDeclarations   {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                                outfile << $$ << "->" << $2 << ";" << endl;}
                        | PackageDeclaration ImportDeclarations TypeDeclarations    {outfile << node << "[label=\"CompilationUnit\"];" << endl;
                                                                                    $$ = node;
                                                                                    node++;
                                                                                    outfile << $$ << "->" << $1 << ";" << endl;
                                                                                    outfile << $$ << "->" << $2 << ";" << endl;
                                                                                    outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
ImportDeclarations      : ImportDeclaration                     {$$ = $1;}
                        | ImportDeclarations ImportDeclaration  {outfile << node << "[label=\"ImportDeclarations\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                                outfile << $$ << "->" << $2 << ";" << endl; }
                        ;
TypeDeclarations        : TypeDeclaration                       {$$ = $1;}
                        | TypeDeclarations TypeDeclaration      {outfile << node << "[label=\"TypeDeclarations\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                                outfile << $$ << "->" << $2 << ";" << endl; }
                        ;
                        ;
PackageDeclaration      : PACKAGE Name SEMICOLON            {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"PackageDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
ImportDeclaration       : SingleTypeImportDeclaration       {$$ = $1;}
                        | TypeImportOnDemandDeclaration     {$$ = $1;}
                        ;
SingleTypeImportDeclaration : IMPORT Name SEMICOLON         {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ImportDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}       
                            ;
TypeImportOnDemandDeclaration   : IMPORT Name DOT STAR SEMICOLON    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                                    int n1 = node;
                                                                    node++;
                                                                    outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                                    int n3 = node;
                                                                    node++;
                                                                    outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                                    int n4 = node;
                                                                    node++;
                                                                    outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                                    int n5 = node;
                                                                    node++;
                                                                    outfile << node << "[label=\"TypeImportOnDemand\"];" << endl;
                                                                    $$ = node;
                                                                    node++;
                                                                    outfile << $$ << "->" << n1 << ";" << endl;
                                                                    outfile << $$ << "->" << $2 << ";" << endl;
                                                                    outfile << $$ << "->" << n3 << ";" << endl;
                                                                    outfile << $$ << "->" << n4 << ";" << endl;
                                                                    outfile << $$ << "->" << n5 << ";" << endl;}
                                ;
TypeDeclaration         : ClassDeclaration              {$$ = $1;}
                        | InterfaceDeclaration          {$$ = $1;}
                        | SEMICOLON                     {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        ;

Literal                 : INT_LITERAL                   {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        | FLOAT_LITERAL                 {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        | BOOL_LITERAL                  {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        | CHAR_LITERAL                  {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;} 
                        | STRING_LITERAL                {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        | NULL_LITERAL                  {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        | TEXT_BLOCK                    {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                        $$ = node;
                                                        node++;}
                        ;

Name                    : SingleName            {$$ = $1;}
                        | MultipleName          {$$ = $1;}
                        ;
SingleName              : IDENTIFIER            {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;}    
                        ;
MultipleName            : Name DOT IDENTIFIER   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                int n2 = node;
                                                node++;
                                                outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                int n3 = node;
                                                node++;
                                                $$ = node;
                                                outfile << node << "[label=\"MultipleName\"];" << endl;
                                                node++;
                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                outfile << $$ << "->" << n2 << ";" << endl;
                                                outfile << $$ << "->" << n3 << ";" << endl;}  
                        ;

Modifiers               : Modifier              {$$ = $1;}           
                        | Modifiers Modifier                    {outfile << node << "[label=\"Modifiers\"];" << endl;
                                                                $$ = node;
                                                                node++;
                                                                outfile << $$ << "->" << $1 << ";" << endl;
                                                                outfile << $$ << "->" << $2 << ";" << endl; }
                        ;
Modifier                : PUBLIC                {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | PROTECTED             {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | PRIVATE               {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | STATIC                {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | ABSTRACT              {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | FINAL                 {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | NATIVE                {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | SYNCHRONIZED          {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | TRANSIENT             {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | VOLATILE              {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        ;

Type                    : PrimitiveType         {$$ = $1;}
                        | ReferenceType         {$$ = $1;}
                        ;
PrimitiveType           : NumericType           {$$ = $1;}
                        | BOOLEAN               {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        ;
NumericType             : INTEGRALTYPE          {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        | FLOATINGPOINTTYPE     {outfile << node << "[label=\"" << $1 <<"\"];" << endl;
                                                $$ = node;
                                                node++;} 
                        ;
ReferenceType           : ClassOrInterfaceType  {$$ = $1;}
                        | ArrayType             {$$ = $1;}
                        ;
ClassOrInterfaceType    : Name                  {$$ = $1;}
                        ;
ClassType               : ClassOrInterfaceType  {$$ = $1;}
                        ;
InterfaceType           : ClassOrInterfaceType  {$$ = $1;}
                        ;
ArrayType               : PrimitiveType OSB CSB             {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ArrayType\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | Name OSB CSB                      {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ArrayType\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | ArrayType OSB CSB                 {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ArrayType\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;

ClassDeclaration        : CLASS IDENTIFIER ClassBody        {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Modifiers CLASS IDENTIFIER ClassBody  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | CLASS IDENTIFIER Super ClassBody  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Modifiers CLASS IDENTIFIER Super ClassBody    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        | CLASS IDENTIFIER Interfaces ClassBody {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | Modifiers CLASS IDENTIFIER Interfaces ClassBody   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        | CLASS IDENTIFIER Super Interfaces ClassBody   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        | Modifiers CLASS IDENTIFIER Super Interfaces ClassBody {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"ClassDeclaration\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
Super                   : EXTENDS ClassType                 {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"Super\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
Interfaces              : IMPLEMENTS InterfaceTypeList      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            $$ = node;
                                                            outfile << node << "[label=\"Interfaces\"];" << endl;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
InterfaceTypeList       : InterfaceType             {$$ = $1;}
                        | InterfaceTypeList COMMA InterfaceType     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfacetypeList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        ;
ClassBody               : OCB CCB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;} 
                        | OCB ClassBodyDeclarations CCB     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
ClassBodyDeclarations   : ClassBodyDeclaration      {$$ = $1;}
                        | ClassBodyDeclarations ClassBodyDeclaration    {outfile << node << "[label=\"ClassBodyDeclarations\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
ClassBodyDeclaration    : ClassMemberDeclaration    {$$ = $1;}
                        | StaticInitializer         {$$ = $1;}
                        | ConstructorDeclaration    {$$ = $1;}
                        | ClassDeclaration          {$$ = $1;}
                        ;
ClassMemberDeclaration  : FieldDeclaration          {$$ = $1;}
                        | MethodDeclaration         {$$ = $1;}
                        ;
FieldDeclaration        : Type VariableDeclarators SEMICOLON        {outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"FieldDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | Modifiers Type VariableDeclarators SEMICOLON  {outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"FieldDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                        ;
VariableDeclarators     : VariableDeclarator        {$$ = $1;}
                        | VariableDeclarators COMMA VariableDeclarator  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"VariableDeclarators\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
VariableDeclarator      : VariableDeclaratorId      {$$ = $1;}
                        | VariableDeclaratorId EQ VariableInitializer   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"VariableDeclarator\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        ;
VariableDeclaratorId    : IDENTIFIER                {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                    $$ = node;
                                                    node++;}   
                        | VariableDeclaratorId OSB CSB  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                        int n2 = node;
                                                        node++;
                                                        outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                        int n3 = node;
                                                        node++;
                                                        outfile << node << "[label=\"VariableDeclaratorId\"];" << endl;
                                                        $$ = node;
                                                        node++;
                                                        outfile << $$ << "->" << $1 << ";" << endl;
                                                        outfile << $$ << "->" << n2 << ";" << endl;
                                                        outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
VariableInitializer     : Expression                {$$ = $1;}
                        | ArrayInitializer          {$$ = $1;}
                        ;
MethodDeclaration       : MethodHeader MethodBody           {outfile << node << "[label=\"MethodDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
MethodHeader            : Type MethodDeclarator             {outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        | Modifiers Type MethodDeclarator   {outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Type MethodDeclarator Throws      {outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Modifiers Type MethodDeclarator Throws    {outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | VOID MethodDeclarator             {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}      
                        | Modifiers VOID MethodDeclarator   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | VOID MethodDeclarator Throws      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Modifiers VOID MethodDeclarator Throws    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodHeader\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        ;
MethodDeclarator        : IDENTIFIER ONB CNB                {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            node++;outfile << node << "[label=\"MethodDeclarator\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | IDENTIFIER ONB FormalParameterList CNB    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodDeclarator\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | MethodDeclarator OSB CSB          {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodDeclarator\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
FormalParameterList     : FormalParameter           {$$ = $1;}
                        | FormalParameterList COMMA FormalParameter     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"FormalParameterlist\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
FormalParameter         : Type VariableDeclaratorId         {outfile << node << "[label=\"FormalParameter\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
Throws                  : THROWS ClassTypeList              {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"Throws\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
ClassTypeList           : ClassType                 {$$ = $1;}
                        | ClassTypeList COMMA ClassType     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassTypelist\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
MethodBody              : Block             {$$ = $1;}
                        | SEMICOLON         {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                            $$ = node;
                                            node++;}
                        ;           
StaticInitializer       : STATIC Block                      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;outfile << node << "[label=\"Staticinitializer\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
ConstructorDeclaration  : ConstructorDeclarator ConstructorBody     {outfile << node << "[label=\"ConstructorDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}  
                        | Modifiers ConstructorDeclarator ConstructorBody   {outfile << node << "[label=\"ConstructorDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | ConstructorDeclarator Throws ConstructorBody      {outfile << node << "[label=\"ConstructorDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Modifiers ConstructorDeclarator Throws ConstructorBody    {outfile << node << "[label=\"ConstructorDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}    
                        ;
ConstructorDeclarator   : SingleName ONB CNB                {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassDeclarator\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | SingleName ONB FormalParameterList CNB    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;outfile << node << "[label=\"ClassDeclarator\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                        ;
ConstructorBody         : OCB CCB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConstructorBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        | OCB ExplicitConstructorInvocation CCB     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConstructorBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | OCB BlockStatements CCB           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConstructorBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | OCB ExplicitConstructorInvocation BlockStatements CCB    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConstructorBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;} 
                        ;
ExplicitConstructorInvocation   : THIS ONB CNB SEMICOLON    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExplicitConstructorInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                                | THIS ONB ArgumentList CNB SEMICOLON   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExplicitConstructorInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;}
                                | SUPER ONB CNB SEMICOLON   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExplicitConstructorInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                                | SUPER ONB ArgumentList CNB SEMICOLON  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExplicitConstructorInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;}
                                ;

InterfaceDeclaration    : INTERFACE IDENTIFIER InterfaceBody    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfaceDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | Modifiers INTERFACE IDENTIFIER InterfaceBody  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfaceDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | INTERFACE IDENTIFIER ExtendsInterfaces InterfaceBody      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfaceDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | Modifiers INTERFACE IDENTIFIER ExtendsInterfaces InterfaceBody    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfaceDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
ExtendsInterfaces       : EXTENDS InterfaceType             {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExtendsInterfaces\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        | ExtendsInterfaces COMMA InterfaceType {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExtendsInterfaces\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
InterfaceBody           : OCB CCB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfaceBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}  
                        | OCB InterfaceMemberDeclarations CCB   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InterfaceBody\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
InterfaceMemberDeclarations : InterfaceMemberDeclaration    {$$ = $1;}
                            | InterfaceMemberDeclarations InterfaceMemberDeclaration    {outfile << node << "[label=\"InterfaceMemberDeclarations\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                            ;
InterfaceMemberDeclaration  : ConstantDeclaration           {$$ = $1;}
                            | AbstractMethodDeclaration     {$$ = $1;}
                            ;
ConstantDeclaration     : FieldDeclaration          {$$ = $1;}
                        ;
AbstractMethodDeclaration   : MethodHeader SEMICOLON        {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"AbstractMethodDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                            ;

ArrayInitializer        : OCB CCB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayInitializer\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        | OCB VariableInitializers CCB      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayInitializer\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | OCB COMMA CCB                     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayInitializer\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | OCB VariableInitializers COMMA CCB   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayInitializer\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;} 
                        ;
VariableInitializers    : VariableInitializer       {$$ = $1;}
                        | VariableInitializers COMMA VariableInitializer    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"VariableInitializers\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;

Block                   : OCB CCB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            node++;
                                                            outfile << node << "[label=\"Block\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}                
                        | OCB BlockStatements CCB           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"Block\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
BlockStatements         : BlockStatement            {$$ = $1;}
                        | BlockStatements BlockStatement     {outfile << node << "[label=\"BlockStatements\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
BlockStatement          : LocalVariableDeclarationStatement {$$ = $1;}
                        | Statement                 {$$ =$1;}
                        ;
LocalVariableDeclarationStatement   : LocalVariableDeclaration SEMICOLON        {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"LocalVariableDeclarationStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                                    ;
LocalVariableDeclaration    : Type VariableDeclarators      {outfile << node << "[label=\"LocalVariableDeclaration\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                            ;
Statement               : StatementWithoutTrailingSubstatement      {$$ = $1;}
                        | LabeledStatement          {$$ = $1;}
                        | IfThenStatement           {$$ = $1;}
                        | IfThenElseStatement       {$$ = $1;}
                        | WhileStatement            {$$ = $1;}
                        | ForStatement              {$$ = $1;}
                        ;
StatementNoShortIf      : StatementWithoutTrailingSubstatement      {$$ = $1;}
                        | LabeledStatementNoShortIf {$$ = $1;}
                        | IfThenElseStatementNoShortIf  {$$ = $1;}  
                        | WhileStatementNoShortIf   {$$ = $1;}
                        | ForStatementNoShortIf     {$$ = $1;}
                        ;
StatementWithoutTrailingSubstatement    : Block     {$$ = $1;}
                                        | EmptyStatement    {$$ = $1;}
                                        | ExpressionStatement   {$$ = $1;}
                                        | SwitchStatement   {$$ = $1;}
                                        | DoStatement   {$$ = $1;}
                                        | BreakStatement    {$$ = $1;}
                                        | ContinueStatement {$$ = $1;}
                                        | ReturnStatement   {$$ = $1;}
                                        | SynchronizedStatement {$$ = $1;}
                                        | ThrowStatement    {$$ = $1;}
                                        | TryStatement  {$$ = $1;}
                                        ;
EmptyStatement          : SEMICOLON                         {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            $$= node;
                                                            node++;}
                        ;
LabeledStatement        : IDENTIFIER COLON Statement        {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"LabeledStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
LabeledStatementNoShortIf   : IDENTIFIER COLON StatementNoShortIf   {outfile << node << "[label=\"" << $1<< "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"LabeledStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                            ;
ExpressionStatement     : StatementExpression SEMICOLON     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExpressionStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        ;
StatementExpression     : Assignment                    {$$ = $1;}
                        | PreIncrementExpression        {$$ = $1;}
                        | PreDecrementExpression        {$$ = $1;}
                        | PostIncrementExpression       {$$ = $1;}
                        | PostDecrementExpression       {$$ = $1;}
                        | MethodInvocation              {$$ = $1;}
                        | ClassInstanceCreationExpression   {$$ = $1;}
                        ;
IfThenStatement         : IF ONB Expression CNB Statement   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"IfThenStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
IfThenElseStatement     : IF ONB Expression CNB StatementNoShortIf ELSE Statement   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"IFThenElseStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        ;
IfThenElseStatementNoShortIf    : IF ONB Expression CNB StatementNoShortIf ELSE StatementNoShortIf  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"IFThenElseStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                                ;
SwitchStatement         : SWITCH ONB Expression CNB SwitchBlock         {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
SwitchBlock             : OCB CCB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchBlock\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        | OCB SwitchLabels CCB              {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchBlock\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | OCB SwitchBlockStatementGroups CCB    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchBlock\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | OCB SwitchBlockStatementGroups SwitchLabels CCB   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchBlock\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                        ;
SwitchBlockStatementGroups  : SwitchBlockStatementGroup     {$$ = $1;}
                            | SwitchBlockStatementGroups SwitchBlockStatementGroup  {outfile << node << "[label=\"SwitchBlockStatementGroups\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                            ;
SwitchBlockStatementGroup   : SwitchLabels BlockStatements  {outfile << node << "[label=\"SwitchBlockStatementGroup\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                            ;
SwitchLabels            : SwitchLabel                       {$$ = $1;}
                        | SwitchLabels SwitchLabel          {outfile << node << "[label=\"SwitchLabels\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
SwitchLabel             : CASE ConstantExpression COLON     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchLabel\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | DEFAULT COLON                     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SwitchLabel\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        ;
WhileStatement          : WHILE ONB Expression CNB Statement    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"WhileStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
WhileStatementNoShortIf : WHILE ONB Expression CNB StatementNoShortIf   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"WhileStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
DoStatement             : DO Statement WHILE ONB Expression CNB SEMICOLON   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"DoStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;}
                        ;
ForStatement            : FOR ONB SEMICOLON SEMICOLON   CNB Statement       {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB Statement {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB Statement  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB Statement  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;
                                                            outfile << $$ << "->" << $8 << ";" << endl;}
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB Statement       {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB Statement   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;}
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;
                                                            outfile << $$ << "->" << $8 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $8 << "\"];" << endl;
                                                            int n8 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;
                                                            outfile << $$ << "->" << n8 << ";" << endl;
                                                            outfile << $$ << "->" << $9 << ";" << endl;}   
                        ;
ForStatementNoShortIf   : FOR ONB SEMICOLON SEMICOLON   CNB StatementNoShortIf  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB StatementNoShortIf    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB StatementNoShortIf     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;
                                                            outfile << $$ << "->" << $8 << ";" << endl;}
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;}
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $7 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;
                                                            outfile << $$ << "->" << $8 << ";" << endl;}    
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $8 << "\"];" << endl;
                                                            int n8 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ForStatementNoShortIf\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;
                                                            outfile << $$ << "->" << $7 << ";" << endl;
                                                            outfile << $$ << "->" << n8 << ";" << endl;
                                                            outfile << $$ << "->" << $9 << ";" << endl;}  
                        ;
ForInit                 : StatementExpressionList       {$$ = $1;}
                        | LocalVariableDeclaration      {$$ = $1;}
                        ;
ForUpdate               : StatementExpressionList       {$$ = $1;}
                        ;
StatementExpressionList : StatementExpression           {$$ = $1;}
                        | StatementExpressionList COMMA StatementExpression     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"StatementExpressionList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
BreakStatement          : BREAK SEMICOLON                   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"BreakStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        | BREAK IDENTIFIER  SEMICOLON       {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"BreakStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
ContinueStatement       : CONTINUE SEMICOLON                {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ContinueStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}   
                        | CONTINUE IDENTIFIER SEMICOLON     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ContinueStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
ReturnStatement         : RETURN SEMICOLON                  {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ReturnStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        | RETURN Expression SEMICOLON       {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ReturnStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
ThrowStatement          : THROW Expression SEMICOLON        {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ThrowStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}  
                        ;
SynchronizedStatement   : SYNCHRONIZED  ONB Expression CNB Block    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"SynchronizedStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
TryStatement            : TRY Block Catches                 {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"TryStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | TRY Block Finally                 {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"TryStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | TRY Block Catches Finally         {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"TryStatement\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        ;
Catches                 : CatchClause                       {$$ = $1;}
                        | Catches CatchClause               {outfile << node << "[label=\"Catches\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
CatchClause             : CATCH ONB FormalParameter CNB Block   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"CatchClause\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
Finally                 : FINALLY Block                     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"Finally\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;} 
                        ;

Primary                 : PrimaryNoNewArray                 {$$ = $1;}
                        | ArrayCreationExpression           {$$ = $1;}
                        ;
PrimaryNoNewArray       : Literal                           {$$ = $1;}
                        | THIS                              {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            $$ = node;
                                                            node++;}
                        | ONB Expression CNB                {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"PrimaryNewArray\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | ClassInstanceCreationExpression   {$$ = $1;}
                        | FieldAccess                       {$$ = $1;}
                        | MethodInvocation                  {$$ = $1;}
                        | ArrayAccess                       {$$ = $1;}
                        ;
ClassInstanceCreationExpression : NEW ClassType ONB CNB     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassInstanceCreationExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;} 
                                | NEW ClassType ONB ArgumentList CNB    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassInstanceCreationExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;}
                                | Name DOT NEW ClassType ONB CNB        {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassInstanceCreationExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;}
                                | Name DOT NEW ClassType ONB ArgumentList CNB   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n7 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ClassInstanceCreationExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;
                                                            outfile << $$ << "->" << $6 << ";" << endl;
                                                            outfile << $$ << "->" << n7 << ";" << endl;}
                                ;
ArgumentList            : Expression                        {$$ = $1;}
                        | ArgumentList COMMA Expression     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArgumentList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
ArrayCreationExpression : NEW PrimitiveType DimExprs        {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayCreationList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | NEW PrimitiveType DimExprs Dims   {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayCreationList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | NEW ClassOrInterfaceType DimExprs {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayCreationList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        | NEW ClassOrInterfaceType DimExprs Dims    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayCreationList\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;} 
                        ;
DimExprs                : DimExpr                           {$$ = $1;}
                        | DimExprs DimExpr                  {outfile << node << "[label=\"DimExprs\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
DimExpr                 : OSB Expression CSB                {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"DimExpr\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}          
                        ;
Dims                    : OSB CSB                           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"Dims\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        | Dims OSB CSB                      {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"Dims\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
FieldAccess             : Primary DOT IDENTIFIER            {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"FieldAccess\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        | SUPER DOT IDENTIFIER              {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"FieldAccess\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}
                        ;
MethodInvocation        : Name ONB CNB                      {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;}   
                        | Name ONB ArgumentList CNB         {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                        | Primary DOT IDENTIFIER ONB CNB    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;}
                        | Primary DOT IDENTIFIER ONB ArgumentList CNB   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;}
                        | SUPER DOT IDENTIFIER ONB CNB      {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $5 << "\"];" << endl;
                                                            int n5 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << n5 << ";" << endl;}
                        | SUPER DOT IDENTIFIER ONB ArgumentList CNB {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $6 << "\"];" << endl;
                                                            int n6 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MethodInvocation\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;
                                                            outfile << $$ << "->" << n6 << ";" << endl;}
                        ;
ArrayAccess             : Name OSB Expression CSB           {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayAccess\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                        | PrimaryNoNewArray OSB Expression CSB  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ArrayAccess\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;}
                        ;
PostfixExpression       : Primary                           {$$ = $1;}
                        | Name                              {$$ = $1;}
                        | PostIncrementExpression           {$$ = $1;}
                        | PostDecrementExpression           {$$ = $1;}
                        ;
PostIncrementExpression : PostfixExpression INC             {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"PostIncrementExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        ;
PostDecrementExpression : PostfixExpression DEC             {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"PostDecrementExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;}
                        ;
UnaryExpression         : PreIncrementExpression            {$$ = $1;}
                        | PreDecrementExpression            {$$ = $1;}
                        | PLUS UnaryExpression              {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"UnaryExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        | MINUS UnaryExpression             {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"UnaryExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        | UnaryExpressionNotPlusMinus       {$$ = $1;}
                        ;   
PreIncrementExpression  : INC UnaryExpression               {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"PreIncrementExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
PreDecrementExpression  : DEC UnaryExpression               {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"PreDecrementExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                        ;
UnaryExpressionNotPlusMinus : PostfixExpression             {$$ = $1;}
                            | NEG UnaryExpression           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"UnaryExpressionNotPlusMinus\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                            | NOT UnaryExpression           {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"UnaryExpressionNotPlusMinus\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;}
                            | CastExpression                {$$ = $1;} 
                            ;   
CastExpression          : ONB PrimitiveType CNB UnaryExpression     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"CastExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | ONB PrimitiveType Dims CNB UnaryExpression    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"CastExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | ONB Expression CNB UnaryExpressionNotPlusMinus    {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $3 << "\"];" << endl;
                                                            int n3 = node;
                                                            node++;
                                                            outfile << node << "[label=\"CastExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << n3 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        | ONB Name Dims CNB UnaryExpressionNotPlusMinus     {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            int n1 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"CastExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << n1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $4 << ";" << endl;}
                        ;
MultiplicativeExpression    : UnaryExpression               {$$ = $1;}
                            | MultiplicativeExpression STAR UnaryExpression {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MultiplicativeExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                            | MultiplicativeExpression DIV UnaryExpression  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MultiplicativeExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                            | MultiplicativeExpression MOD UnaryExpression  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"MultiplicativeExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                            ;
AdditiveExpression      : MultiplicativeExpression          {$$ = $1;}
                        | AdditiveExpression PLUS MultiplicativeExpression  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"AdditiveExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        | AdditiveExpression MINUS MultiplicativeExpression {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"AdditiveExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        ;
ShiftExpression         : AdditiveExpression                {$$ = $1;}
                        | ShiftExpression SHIFT AdditiveExpression   {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ShiftExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}    
                        ;
RelationalExpression    : ShiftExpression                   {$$ = $1;}
                        | RelationalExpression RELGL ShiftExpression    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"RelationalExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | RelationalExpression INSTANCEOF ReferenceType {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"RelationalExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
EqualityExpression      : RelationalExpression              {$$ = $1;}
                        | EqualityExpression RELEQ RelationalExpression {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"EqualityExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        | EqualityExpression RELNOTEQ RelationalExpression  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"EqualityExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        ;
AndExpression           : EqualityExpression                {$$ = $1;}
                        | AndExpression AND EqualityExpression  {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"AndExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
ExclusiveOrExpression   : AndExpression                     {$$ = $1;}
                        | ExclusiveOrExpression UP AndExpression    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ExclusiveOrExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
InclusiveOrExpression   : ExclusiveOrExpression             {$$ = $1;}
                        | InclusiveOrExpression OR ExclusiveOrExpression    {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"InclusiveOrExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                        ;
ConditionalAndExpression    : InclusiveOrExpression         {$$ = $1;}
                            | ConditionalAndExpression RELAND InclusiveOrExpression     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConditionalAndExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}
                            ;
ConditionalOrExpression : ConditionalAndExpression          {$$ = $1;}
                        | ConditionalOrExpression RELOR ConditionalAndExpression        {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConditionalOrExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;} 
                        ;
ConditionalExpression   : ConditionalOrExpression           {$$ = $1;}
                        | ConditionalOrExpression QM Expression COLON ConditionalExpression     {outfile << node << "[label=\"" << $2 << "\"];" << endl;
                                                            int n2 = node;
                                                            node++;
                                                            outfile << node << "[label=\"" << $4 << "\"];" << endl;
                                                            int n4 = node;
                                                            node++;
                                                            outfile << node << "[label=\"ConditonalExpression\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << n2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;
                                                            outfile << $$ << "->" << n4 << ";" << endl;
                                                            outfile << $$ << "->" << $5 << ";" << endl;}
                        ;
AssignmentExpression    : ConditionalExpression             {$$ = $1;}
                        | Assignment                        {$$ = $1;}
                        ;
Assignment              : LeftHandSide Assignment_Operators AssignmentExpression    {outfile << node << "[label=\"Assignment\"];" << endl;
                                                            $$ = node;
                                                            node++;
                                                            outfile << $$ << "->" << $1 << ";" << endl;
                                                            outfile << $$ << "->" << $2 << ";" << endl;
                                                            outfile << $$ << "->" << $3 << ";" << endl;}   
                        ;
Assignment_Operators    : ASSIGNMENT_OPERATOR               {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            $$ = node;
                                                            node++;}
                        | EQ                                {outfile << node << "[label=\"" << $1 << "\"];" << endl;
                                                            $$ = node;
                                                            node++;}
                        ;
LeftHandSide            : Name                              {$$ = $1;}
                        | FieldAccess                       {$$ = $1;}
                        | ArrayAccess                       {$$ = $1;}
                        ;
Expression              : AssignmentExpression              {$$ = $1;}
                        ;   
ConstantExpression      : Expression                        {$$ = $1;}
                        ;

%%                      


int main (int argc, char** argv) {

    if(argc!=3)
    {
        cout << "The syntax for execution is: program input_filename" << endl;
        return 0;
    }

    FILE *infile = fopen(argv[1], "r");
    outfile.open(argv[2], ios::trunc);
    if (!infile) {
        cout << "I can't open the file!" << endl;
        return -1;
    }
    yyin = infile;
    outfile << "digraph G{" << endl << "ordering=\"out\";" << endl;
    yyparse();
    outfile << "}" << endl;
    fclose(infile);

	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nFor the Token:%s\nIn Line number:%d\n", s, yytext, yylineno);} 
