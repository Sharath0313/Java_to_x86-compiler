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

%start Block
%token<str> relor reland releq relnoteq shift relgl
%token<str> AssignmentOperator dots NumericType var IDENTIFIER IF ELSE ASSERT THROW TRY CATCH SWITCH arrow CASE DEFAULT WHILE DO FOR BREAK YIELD CONTINUE RETURN finally THIS synchronized CLASS boolean VOID NEW super instanceof
%type<str> Block BlockStatement BlockStatements SwitchBlock LocalClassOrInterfaceDeclaration LocalVariableDeclaration LocalVariableDeclarationStatement LocalVariableType LabeledStatementNoShortIf
%type<str> VariableAccess VariableDeclaratorId VariableDeclaratorList VariableModifier UnannClassType NormalInterfaceDeclaration Statement StatementExpression StatementExpressionList StatementNoShortIf StatementWithoutTrailingSubstatement SBSG SL SR
%type<str> ClassDeclaration LabeledStatement FIit ForInit ForStatement ForStatementNoShortIf ForUpdate IfThenElseStatement IfThenElseStatementNoShortIf IfThenStatement WhileStatement WhileStatementNoShortIf
%type<str> EmptyStatement EnhancedForStatement EnhancedForStatementNoShortIf BasicForStatement BasicForStatementNoShortIf BreakStatement AssertStatement Assignment CaseConstant CatchClause Catches CatchFormalParameter CatchType CC ConditionalExpression
%type<str> Expression ExpressionStatement SwitchBlockStatementGroup SwitchLabel SwitchRule SwitchStatement DoStatement ContinueStatement Resource ResourceList ResourceSpecification ReturnStatement
%type<str> ThrowStatement TryStatement TryWithResourcesStatement YieldStatement SynchronizedStatement ClassInstanceCreationExpression 
%type<str> CT Finally Pattern TypePattern MethodInvocation MethodReference MethodName UnannType 
%type<str> Primary PrimaryNoNewArray PrimitiveType Ann AnnI ArrayCreationExpression TypeName FieldAccess ArrayAccess ClassLiteral SqBrackets UnqualifiedClassInstanceCreationExpression ExpressionName 
%type<str> ClassOrInterfaceType ClassOrInterfaceTypeToInstantiate ClassBody TypeArguments TypeArgumentsOrDiamond ArgumentList ArrayType ClassType ArrayInitializer DimExpr DimExprs Dims
%type<str> LambdaExpression AssignmentExpression LambdaParameter LambdaParameterList LambdaParameters LambdaParameterType LPL IL VariableArityParameter LambdaBody LeftHandSide AssignmentOperator 
%type<str> ConditionalAndExpression ConditionalOrExpression InclusiveOrExpression ExclusiveOrExpression AndExpression EqualityExpression RelationalExpression ShiftExpression InstanceofExpression AdditionalBound AdditiveExpression MultiplicativeExpression UnaryExpression UnaryExpressionNotPlusMinus
%type<str> PostfixExpression CastExpression SwitchExpression ReferenceType AB ConstantExpression

%%

Literal : INT_LITERAL
        | FLOAT_LITERAL
        | CHAR_LITERAL
        | BOOL_LITERAL
        | STRING_LITERAL
        | NULL_LITERAL
        | TEXT_BLOCK
        ;
/*BLOCKS*/
Block   : '{' BlockStatements '}' 
		| '{' '}'
        ;
BlockStatements	: BlockStatements BlockStatement
				| BlockStatement
                ;
BlockStatement 	: LocalClassOrInterfaceDeclaration
				| LocalVariableDeclarationStatement
				| Statement
                ;
LocalClassOrInterfaceDeclaration	: ClassDeclaration
						            | NormalInterfaceDeclaration
                                    ;
LocalVariableDeclarationStatement 	: LocalVariableDeclaration ';'
                                    ;
LocalVariableDeclaration	: LocalVariableType VariableDeclaratorList
							| VariableModifier LocalVariableDeclaration
                            ;
LocalVariableType	: UnannType
				    | var
                    ;
Statement	: StatementWithoutTrailingSubstatement
			| LabeledStatement
			| IfThenStatement
			| IfThenElseStatement
			| WhileStatement
			| ForStatement
            ;
StatementNoShortIf	: StatementWithoutTrailingSubstatement
				    | LabeledStatementNoShortIf
				    | IfThenElseStatementNoShortIf
		    		| WhileStatementNoShortIf
			    	| ForStatementNoShortIf
                    ;
StatementWithoutTrailingSubstatement	: Block
							| EmptyStatement
							| ExpressionStatement
							| AssertStatement
							| SwitchStatement
							| DoStatement
							| BreakStatement
							| ContinueStatement
							| ReturnStatement
							| SynchronizedStatement
							| ThrowStatement
							| TryStatement
							| YieldStatement
                            ;
EmptyStatement  :	';'
                ;
LabeledStatement	: IDENTIFIER ':' Statement
                    ;
LabeledStatementNoShortIf	: IDENTIFIER ':' StatementNoShortIf
                            ;
ExpressionStatement	    : StatementExpression ';'
                        ;
StatementExpression     : Assignment
				| PreIncrementExpression
				| PreDecrementExpression
				| PostIncrementExpression
				| PostDecrementExpression
				| MethodInvocation
				| ClassInstanceCreationExpression
                ;
IfThenStatement :	IF '(' Expression ')' Statement
                ;
IfThenElseStatement	: IF '(' Expression ')' StatementNoShortIf ELSE Statement
                    ;
IfThenElseStatementNoShortIf	: IF '(' Expression ')' StatementNoShortIf ELSE StatementNoShortIf
                                ;
AssertStatement	: ASSERT Expression ';'
				| ASSERT Expression ':' Expression ';'
                ;
SwitchStatement	: SWITCH '(' Expression ')' SwitchBlock
                ;
SwitchBlock	: '{' SR '}'
			| '{' '}'
			| '{' SBSG '}'
			| '{' SBSG SL '}'
			| '{' SL '}'
            ;
SR  	: SR SwitchRule
		| SwitchRule
        ;
SBSG	: SBSG SwitchBlockStatementGroup
		|  SwitchBlockStatementGroup
        ;
SL  	: SL SwitchLabel ':'
		| SwitchLabel
        ;
SwitchRule	: SwitchLabel arrow Expression ';'
			| SwitchLabel arrow Block
			| SwitchLabel arrow ThrowStatement
            ;
SwitchBlockStatementGroup	: SL SwitchLabel ':' BlockStatements
                            ;
SwitchLabel	: CASE CC
			| DEFAULT
            ;
CC  	: CC ',' CaseConstant 
		| CaseConstant
        ;
CaseConstant	: ConditionalExpression
                ;
WhileStatement  : WHILE '(' Expression ')' Statement
                ;
WhileStatementNoShortIf	: WHILE '(' Expression ')' StatementNoShortIf
                        ;
DoStatement 	: DO Statement WHILE '(' Expression ')' ';'
                ;
ForStatement	: BasicForStatement
				| EnhancedForStatement
                ;
ForStatementNoShortIf	: BasicForStatementNoShortIf
					| EnhancedForStatementNoShortIf
                    ;
BasicForStatement	: FOR '(' FIit ';' E ';' FU ')' Statement
                    ;
FIit	: ForInit
		| 
        ;
E       : Expression
		| 
        ;
FU   	: ForUpdate
		| 
        ;
BasicForStatementNoShortIf	: FOR '(' FIit ';' E ';' FU ')' StatementNoShortIf
                            ;
ForInit	    : StatementExpressionList
			| LocalVariableDeclaration
            ;
ForUpdate	: StatementExpressionList
            ;
StatementExpressionList	: StatementExpressionList ',' StatementExpression
					| StatementExpression
                    ;
EnhancedForStatement	: FOR '(' LocalVariableDeclaration ':' Expression ')' Statement
                        ;
EnhancedForStatementNoShortIf   : FOR '(' LocalVariableDeclaration ':' Expression ')' StatementNoShortIf
                                ;
BreakStatement	: BREAK IDENTIFIER ';'
				| BREAK ';'
                ;
YieldStatement	: YIELD Expression ';'
                ;
ContinueStatement	: CONTINUE IDENTIFIER ';'
				| CONTINUE ';'
                ;
ReturnStatement	: RETURN Expression ';'
				| RETURN ';'
                ;
ThrowStatement	: THROW Expression ';'
                ;
SynchronizedStatement	: synchronized '(' Expression ')' Block
                        ;
TryStatement	: TRY Block Catches
				| TRY Block Catches Finally
				| TRY Block Finally
				| TryWithResourcesStatement
                ;
Catches	    : Catches CatchClause
			| CatchClause
            ;
CatchClause	: CATCH '(' CatchFormalParameter ')' Block
            ;
CatchFormalParameter    : CatchType VariableDeclaratorId
						| VariableModifier CatchFormalParameter
                        ;
CatchType	: UnannClassType '|' CT 
			| UnannClassType
            ;
CT          : CT '|' ClassType 
            | ClassType
            ;
Finally	    : finally Block
            ;
TryWithResourcesStatement   : TRY ResourceSpecification Block Catches Finally
					| TRY ResourceSpecification Block Catches 
					| TRY ResourceSpecification Block Finally
					| TRY ResourceSpecification Block 
                    ;
ResourceSpecification	: '(' ResourceList ';' ')'
					| '(' ResourceList ')'
                    ;
ResourceList	: ResourceList ';' Resource
			| Resource
            ;
Resource	: LocalVariableDeclaration
			| VariableAccess
            ;
Pattern	    : TypePattern
            ;
TypePattern	: LocalVariableDeclaration
            ;
/*EXPRESSIONS*/
Primary 	: PrimaryNoNewArray
			| ArrayCreationExpression
            ;
PrimaryNoNewArray	: Literal
				| ClassLiteral
				| THIS
				| TypeName '.' THIS
				| '(' Expression ')'
				| ClassInstanceCreationExpression
				| FieldAccess
				| ArrayAccess
				| MethodInvocation
				| MethodReference
                ;
ClassLiteral   	: TypeName SqBrackets '.' CLASS
			| NumericType SqBrackets '.' CLASS
			| boolean SqBrackets '.' CLASS
			| VOID '.' CLASS
			| TypeName '.' CLASS
			| NumericType '.' CLASS
			| boolean '.' CLASS
            ;
SqBrackets	: SqBrackets '[' ']'
			| '[' ']'
            ;
ClassInstanceCreationExpression : UnqualifiedClassInstanceCreationExpression
	                            | ExpressionName '.' UnqualifiedClassInstanceCreationExpression
	                            | Primary '.' UnqualifiedClassInstanceCreationExpression
                                ;
UnqualifiedClassInstanceCreationExpression  : NEW TypeArguments ClassOrInterfaceTypeToInstantiate '(' ArgumentList ')' ClassBody
											| NEW ClassOrInterfaceTypeToInstantiate '(' ArgumentList ')' ClassBody
											| NEW TypeArguments ClassOrInterfaceTypeToInstantiate '(' ')' ClassBody
											| NEW ClassOrInterfaceTypeToInstantiate '(' ')' ClassBody
											| NEW TypeArguments ClassOrInterfaceTypeToInstantiate '(' ArgumentList ')' 
											| NEW ClassOrInterfaceTypeToInstantiate '(' ArgumentList ')' 
											| NEW TypeArguments ClassOrInterfaceTypeToInstantiate '(' ')' 
											| NEW ClassOrInterfaceTypeToInstantiate '(' ')' 
                                            ;
ClassOrInterfaceTypeToInstantiate   : Ann IDENTIFIER AnnI TypeArgumentsOrDiamond
	                                | Ann IDENTIFIER AnnI 
                                    ;
Ann 	: Ann Annotation
		| 
        ;
AnnI	: AnnI '.' Ann IDENTIFIER
		| 
        ;
TypeArgumentsOrDiamond	: TypeArguments
					| '<' '>'
                    ;
FieldAccess	: Primary '.' IDENTIFIER
			| super '.' IDENTIFIER
			| TypeName '.' super '.' IDENTIFIER
            ;
ArrayAccess	: ExpressionName '[' Expression ']'
			| PrimaryNoNewArray '[' Expression ']'
            ;
MethodInvocation	: MethodName '(' ArgumentList ')'
				| TypeName '.' TypeArguments IDENTIFIER '(' ArgumentList ')'
				| ExpressionName '.' TypeArguments IDENTIFIER '(' ArgumentList ')'
				| Primary '.' TypeArguments IDENTIFIER '(' ArgumentList ')'
				| super '.' TypeArguments IDENTIFIER '(' ArgumentList ')'
				| TypeName '.' super '.' TypeArguments IDENTIFIER '(' ArgumentList ')'
				| MethodName '(' ')'
				| TypeName '.' TypeArguments IDENTIFIER '(' ')'
				| ExpressionName '.' TypeArguments IDENTIFIER '(' ')'
				| Primary '.' TypeArguments IDENTIFIER '(' ')'
				| super '.' TypeArguments IDENTIFIER '(' ')'
				| TypeName '.' super '.' TypeArguments IDENTIFIER '(' ')'
				| TypeName '.' IDENTIFIER '(' ArgumentList ')'
				| ExpressionName '.' IDENTIFIER '(' ArgumentList ')'
				| Primary '.' IDENTIFIER '(' ArgumentList ')'
				| super '.' IDENTIFIER '(' ArgumentList ')'
				| TypeName '.' super '.' IDENTIFIER '(' ArgumentList ')'
				| TypeName '.' IDENTIFIER '(' ')'
				| ExpressionName '.' IDENTIFIER '(' ')'
				| Primary '.' IDENTIFIER '(' ')'
				| super '.' IDENTIFIER '(' ')'
				| TypeName '.' super '.' IDENTIFIER '(' ')'
                ;
ArgumentList	:	ArgumentList ',' Expression 
				| Expression
                ;
MethodReference	: ExpressionName scope IDENTIFIER
				| Primary scope IDENTIFIER
				| ReferenceType scope IDENTIFIER
				| super scope IDENTIFIER
				| TypeName '.' super scope IDENTIFIER
				| ClassType scope NEW
				| ArrayType scope NEW
				| ExpressionName scope TypeArguments IDENTIFIER
				| Primary scope TypeArguments IDENTIFIER
				| ReferenceType scope TypeArguments IDENTIFIER
				| super scope TypeArguments IDENTIFIER
				| TypeName '.' super scope TypeArguments IDENTIFIER
				| ClassType scope TypeArguments NEW
                ;
ArrayCreationExpression	: NEW PrimitiveType DimExprs Dims
					| NEW PrimitiveType DimExprs
					|  NEW ClassOrInterfaceType DimExprs Dims
					|  NEW ClassOrInterfaceType DimExprs 
					| NEW PrimitiveType Dims ArrayInitializer
					| NEW ClassOrInterfaceType Dims ArrayInitializer
                    ;
DimExprs	: DimExprs DimExpr
			| DimExpr
            ;
DimExpr	    : Ann '[' Expression ']'
            ;
Expression	: LambdaExpression
			| AssignmentExpression
            ;
LambdaExpression	: LambdaParameters arrow LambdaBody
                    ;
LambdaParameters	: '(' LambdaParameterList ')'
				| '(' ')'
				| IDENTIFIER
                ;
LambdaParameterList	: LPL
					| IL
                    ;
LPL	    : LPL ',' LambdaParameter
		| LambdaParameter
        ;
IL  	: IL ',' IDENTIFIER
		| IDENTIFIER
        ;
LambdaParameter	: LambdaParameterType VariableDeclaratorId
				| UnannType Ann dots Identifier
				| VariableModifier LambdaParameter
                ;
LambdaParameterType	: UnannType
					| var
                    ;
LambdaBody	: Expression
			| Block
            ;
AssignmentExpression	: ConditionalExpression
					| Assignment
                    ;
Assignment	: LeftHandSide AssignmentOperator Expression
            ;
LeftHandSide	: ExpressionName
				| FieldAccess
				| ArrayAccess
                ;
ConditionalExpression	: ConditionalOrExpression
			| ConditionalOrExpression '?' Expression ':' ConditionalExpression
			| ConditionalOrExpression '?' Expression ':' LambdaExpression
            ;
ConditionalOrExpression	: ConditionalAndExpression
				| ConditionalOrExpression relor ConditionalAndExpression
                ;
ConditionalAndExpression	: InclusiveOrExpression
				| ConditionalAndExpression reland InclusiveOrExpression
                ;
InclusiveOrExpression	: ExclusiveOrExpression
					| InclusiveOrExpression '|' ExclusiveOrExpression
                    ;
ExclusiveOrExpression	: AndExpression
					| ExclusiveOrExpression '^' AndExpression
                    ;
AndExpression   : EqualityExpression
				| AndExpression '&' EqualityExpression
                ;
EqualityExpression	: RelationalExpression
				| EqualityExpression releq RelationalExpression
				| EqualityExpression relnoteq RelationalExpression
                ;
RelationalExpression	:	ShiftExpression
					| RelationalExpression relgl ShiftExpression
					| InstanceofExpression
                    ;
InstanceofExpression	: RelationalExpression instanceof ReferenceType
					| RelationalExpression instanceof Pattern
                    ;
ShiftExpression : AdditiveExpression
				| ShiftExpression shift AdditiveExpression
                ;
AdditiveExpression	: MultiplicativeExpression
				| AdditiveExpression '+' MultiplicativeExpression
				| AdditiveExpression '-' MultiplicativeExpression
                ;
MultiplicativeExpression	: UnaryExpression
					| MultiplicativeExpression '*' UnaryExpression
					| MultiplicativeExpression '/' UnaryExpression
					| MultiplicativeExpression '%' UnaryExpression
                    ;
UnaryExpression	: PreIncrementExpression
				| PreDecrementExpression
				| '+' UnaryExpression
				| '-' UnaryExpression
				| UnaryExpressionNotPlusMinus
                ;
PreIncrementExpression	: inc UnaryExpression
                        ;
PreDecrementExpression	: dec UnaryExpression
                        ;
UnaryExpressionNotPlusMinus	: PostfixExpression
						| '~' UnaryExpression
						| '!' UnaryExpression
						| CastExpression
						| SwitchExpression
                        ;
PostfixExpression	: Primary
				| ExpressionName
				| PostIncrementExpression
				| PostDecrementExpression
                ;
PostIncrementExpression	: PostfixExpression inc
                        ;
PostDecrementExpression	: PostfixExpression dec
                        ;
CastExpression	: '(' PrimitiveType ')' UnaryExpression
			| '(' ReferenceType AB ')' UnaryExpressionNotPlusMinus
			| '(' ReferenceType AB ')' LambdaExpression
            ;
AB	: AB AdditionalBound
		| 
        ;
SwitchExpression	: SWITCH '(' Expression ')' SwitchBlock
                    ;
ConstantExpression	: Expression
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
