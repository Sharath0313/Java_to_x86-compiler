%option yylineno
%{
#include<iostream>
#include <fstream>
#include <map>
#include <vector>
using namespace std;

#include "java_parser.tab.h"

%}

%%
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]|[/][/].*[\n]|[ \t\n\r\f]|[\r][\n] ;
int|long|char return INTEGRALTYPE;
float|double return FLOATINGPOINTTYPE;
boolean return BOOLEAN;
extends return EXTENDS;
super return SUPER;
interface return INTERFACE;
public return PUBLIC;
protected return PROTECTED;
private return PRIVATE;
abstract return ABSTRACT;
static return STATIC;
final return FINAL;
default return DEFAULT;
class return CLASS;
implements return IMPLEMENTS;
throws return THROWS;
this return THIS;
synchronized return SYNCHRONIZED;
void return VOID;
switch return SWITCH;
continue return CONTINUE;
for return FOR;
new return NEW;
if return IF;
do return DO;
break return BREAK;
throw return THROW;
else return ELSE;
case return CASE;
instaceof return INSTANCEOF;
return return RETURN;
transient return TRANSIENT;
catch return CATCH;
try return TRY;
finally return FINALLY;
volatile return VOLATILE;
native return NATIVE;
while return WHILE;
package return PACKAGE;
import return IMPORT;
null return NULL_LITERAL;
true|false return BOOL_LITERAL;
"*="|"/="|"%="|"+="|"-="|"<<="|">>="|">>>="|"&="|"^="|"|=" return ASSIGNMENT_OPERATOR;
"++" return INC;
"--" return DEC;
"&&" return RELAND;
"||" return RELOR;
"==" return RELEQ;
"!=" return RELNOTEQ;
"<<"|">>"|">>>" return SHIFT;
">"|"<"|"<="|">=" return RELGL;
; return SEMICOLON;
"." return DOT;
"*" return STAR;
"[" return OSB;
"]" return CSB;
"," return COMMA;
"{" return OCB;
"}" return CCB;
"(" return ONB;
")" return CNB;
":" return COLON;
"+" return PLUS;
"-" return MINUS;
"~" return NEG;
"!" return NOT;
"/" return DIV;
"%" return MOD;
"&" return AND;
"^" return UP;
"|" return OR;
"?" return QM;
"=" return EQ;
-{0,1}([1-9][0-9]*(l|L){0,1}|[0](l|L){0,1}) return INT_LITERAL;
-{0,1}(0(x|X)[0-9a-fA-F]+(l|L){0,1}) return INT_LITERAL;
-{0,1}(0[0-7]+(l|L){0,1}) return INT_LITERAL;
-{0,1}(0(b|B)[01]+(l|L){0,1}) return INT_LITERAL;
-{0,1}[0-9]+"."[0-9]+((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D){0,1} return FLOAT_LITERAL;
-{0,1}"."[0-9]+((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D){0,1} return FLOAT_LITERAL;
-{0,1}[1-9][0-9]*(e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} return FLOAT_LITERAL;
-{0,1}([1-9][0-9]*|0)((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D) return FLOAT_LITERAL;
-{0,1}[0-9]+"."((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D) return FLOAT_LITERAL;
-{0,1}[0-9]+"."(e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} return FLOAT_LITERAL;
-{0,1}[0-9]+"."/([^..]|"."{3}|[\n]) return FLOAT_LITERAL;
-{0,1}0(x|X)[0-9a-fA-F]+"."[0-9a-fA-F]*(p|P)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} return FLOAT_LITERAL;
-{0,1}0(x|X)[0-9a-fA-F]*"."[0-9a-fA-F]+(p|P)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} return FLOAT_LITERAL;
'(\\.|[^'])' return CHAR_LITERAL;
\"(\\.|[^"\\])*\" return STRING_LITERAL;
\"\"\"(\\.|\n|[^"]|\"[^"]|\"\"[^"])*[\n|\r|\r\n](\\.|\n|[^"]|\"[^"]|\"\"[^"])*\"\"\" return TEXT_BLOCK;
[_]*[_a-zA-Z][_a-zA-Z0-9]* return IDENTIFIER;
. ;
%%

int yywrap(void){
    return 1;
}