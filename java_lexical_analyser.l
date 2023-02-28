%option yylineno
%{
#include<iostream>
#include <fstream>
#include <map>
#include <vector>
using namespace std;

#define KEYWORD 1
#define IDENTIFIER 2
#define OPERATOR 3
#define SEPARATOR 4
#define INT_LITERAL 5
#define FLOAT_LITERAL 6
#define BOOL_LITERAL 7
#define CHAR_LITERAL 8
#define STRING_LITERAL 9
#define TEXT_BLOCK 10
#define NULL_LITERAL 11
#define ERROR 12
#define Intergral_Type 13
%}

%%
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]|[/][/].*[\n]|[ \t\n\r\f]|[\r][\n] ;
int|long|char IntergralType;
float|double FloatingPointType;
boolean boolean;
extends extends;
super super;
abstract|continue|for|new|switch|assert|default|if|package|synchronized|do|goto|private|this|break|double|implements|protected|throw|byte|else|import|public|throws|case|enum|instanceof|return|transient|catch|extends|int|short|try|char|final|interface|static|void|class|finally|long|strictfp|volatile|const|float|native|super|while|_ return KEYWORD;
null return NULL_LITERAL;
true|false return BOOL_LITERAL;
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
[_]*[_a-zA-Z][_a-zA-Z0-9]* return Identifier;
[(){};,@]|"["|"]"|"."|"."{3}|:{2} return SEPARATOR;
.  return ERROR;
%%

int yywrap(void){
    return 1;
}