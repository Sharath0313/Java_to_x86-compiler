%option yylineno
%{
#include<iostream>
#include <fstream>
#include <map>
#include <vector>
using namespace std;

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
sealed return SEALED;
non-sealed return NON-SEALED;
strictfp return STRICTFP;
permits return PERMITS;
final return FINAL;
default return DEFAULT;
class return CLASS;
implements return IMPLEMENTS;
throws return THROWS;
this return THIS;
synchronized return SYNCHRONIZED;
enum return ENUM;
void return VOID;
switch return SWITCH;
continue return CONTINUE;
for return FOR;
new return NEW;
assert return ASSERT;
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
yield return YIELD;
record return RECORD;
var return VAR;
package return PACKAGE;
import return IMPORT;
goto|byte|short|const|_ return KEYWORD;
null return NULL_LITERAL;
true|false return BOOL_LITERAL;
"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|">>>="|"&="|"^="|"|=" return ASSIGNMENT_OPERATOR;
"++" return INC;
"--" return DEC;
"::" return SCOPE;
"..." return DOTS;
"&&" return RELAND;
"||" return RELOR;
"==" return RELEQ;
"!=" return RELNOTEQ;
"<<"|">>"|">>>" return SHIFT;
">"|"<"|"<="|">=" return RELGL;
"->" return ARROW;
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
[=!?:+/^%]|"~"|[-][>]|={2}|[>][=]|[<][=]|[!][=]|&{1,2}|"|"{1,2}|"+"{1,2}|"-"{1,2}|"*"|<{1,2}|>{1,3}|([+/&^%]|"-"|"*"|"|"|<{2}|>{2,3})= return OPERATOR;
[_]*[_a-zA-Z][_a-zA-Z0-9]* return IDENTIFIER;
[(){};,@]|"["|"]"|"."|"."{3}|:{2} return SEPARATOR;
.  return ERROR;
%%

int yywrap(void){
    return 1;
}