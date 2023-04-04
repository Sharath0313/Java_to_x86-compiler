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
int|long|char {yylval.str = strdup(yytext);return INTEGRALTYPE;}
float|double {yylval.str = strdup(yytext);return FLOATINGPOINTTYPE;}
String {yylval.str = strdup(yytext);return STRINGTYPE;}
boolean {yylval.str = strdup(yytext);return BOOLEAN;}
extends {yylval.str = strdup(yytext);return EXTENDS;}
super {yylval.str = strdup(yytext);return SUPER;}
interface {yylval.str = strdup(yytext);return INTERFACE;}
public {yylval.str = strdup(yytext);return PUBLIC;}
protected {yylval.str = strdup(yytext);return PROTECTED;}
private {yylval.str = strdup(yytext);return PRIVATE;}
abstract {yylval.str = strdup(yytext);return ABSTRACT;}
static {yylval.str = strdup(yytext);return STATIC;}
final {yylval.str = strdup(yytext);return FINAL;}
default {yylval.str = strdup(yytext);return DEFAULT;}
class {yylval.str = strdup(yytext);return CLASS;}
implements {yylval.str = strdup(yytext);return IMPLEMENTS;}
throws {yylval.str = strdup(yytext);return THROWS;}
this {yylval.str = strdup(yytext);return THIS;}
synchronized {yylval.str = strdup(yytext);return SYNCHRONIZED;}
void {yylval.str = strdup(yytext);return VOID;}
switch {yylval.str = strdup(yytext);return SWITCH;}
continue {yylval.str = strdup(yytext);return CONTINUE;}
for {yylval.str = strdup(yytext);return FOR;}
new {yylval.str = strdup(yytext);return NEW;}
if {yylval.str = strdup(yytext);return IF;}
do {yylval.str = strdup(yytext);return DO;}
break {yylval.str = strdup(yytext);return BREAK;}
throw {yylval.str = strdup(yytext);return THROW;}
else {yylval.str = strdup(yytext);return ELSE;}
case {yylval.str = strdup(yytext);return CASE;}
instaceof {yylval.str = strdup(yytext);return INSTANCEOF;}
return {yylval.str = strdup(yytext);return RETURN;}
transient {yylval.str = strdup(yytext);return TRANSIENT;}
catch {yylval.str = strdup(yytext);return CATCH;}
try {yylval.str = strdup(yytext);return TRY;}
finally {yylval.str = strdup(yytext);return FINALLY;}
volatile {yylval.str = strdup(yytext);return VOLATILE;}
native {yylval.str = strdup(yytext);return NATIVE;}
while {yylval.str = strdup(yytext);return WHILE;}
package {yylval.str = strdup(yytext);return PACKAGE;}
import {yylval.str = strdup(yytext);return IMPORT;}
null {yylval.str = strdup(yytext);return NULL_LITERAL;}
true|false {yylval.str = strdup(yytext);return BOOL_LITERAL;}
"*="|"/="|"%="|"+="|"-="|"<<="|">>="|">>>="|"&="|"^="|"|=" {yylval.str = strdup(yytext);return ASSIGNMENT_OPERATOR;}
"++" {yylval.str = strdup(yytext);return INC;}
"--" {yylval.str = strdup(yytext);return DEC;}
"&&" {yylval.str = strdup(yytext);return RELAND;}
"||" {yylval.str = strdup(yytext);return RELOR;}
"==" {yylval.str = strdup(yytext);return RELEQ;}
"!=" {yylval.str = strdup(yytext);return RELNOTEQ;}
"<<"|">>"|">>>" {yylval.str = strdup(yytext);return SHIFT;}
">"|"<"|"<="|">=" {yylval.str = strdup(yytext);return RELGL;}
";" {yylval.str = strdup(yytext);return SEMICOLON;}
"." {yylval.str = strdup(yytext);return DOT;}
"*" {yylval.str = strdup(yytext);return STAR;}
"[" {yylval.str = strdup(yytext);return OSB;}
"]" {yylval.str = strdup(yytext);return CSB;}
"," {yylval.str = strdup(yytext);return COMMA;}
"{" {yylval.str = strdup(yytext);return OCB;}
"}" {yylval.str = strdup(yytext);return CCB;}
"(" {yylval.str = strdup(yytext);return ONB;}
")" {yylval.str = strdup(yytext);return CNB;}
":" {yylval.str = strdup(yytext);return COLON;}
"+" {yylval.str = strdup(yytext);return PLUS;}
"-" {yylval.str = strdup(yytext);return MINUS;}
"~" {yylval.str = strdup(yytext);return NEG;}
"!" {yylval.str = strdup(yytext);return NOT;}
"/" {yylval.str = strdup(yytext);return DIV;}
"%" {yylval.str = strdup(yytext);return MOD;}
"&" {yylval.str = strdup(yytext);return AND;}
"^" {yylval.str = strdup(yytext);return UP;}
"|" {yylval.str = strdup(yytext);return OR;}
"?" {yylval.str = strdup(yytext);return QM;}
"=" {yylval.str = strdup(yytext);return EQ;}
-{0,1}([1-9][0-9]*(l|L){0,1}|[0](l|L){0,1}) {yylval.str = strdup(yytext);return INT_LITERAL;}
-{0,1}(0(x|X)[0-9a-fA-F]+(l|L){0,1}) {yylval.str = strdup(yytext);return INT_LITERAL;}
-{0,1}(0[0-7]+(l|L){0,1}) {yylval.str = strdup(yytext);return INT_LITERAL;}
-{0,1}(0(b|B)[01]+(l|L){0,1}) {yylval.str = strdup(yytext);return INT_LITERAL;}
-{0,1}[0-9]+"."[0-9]+((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D){0,1} {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}"."[0-9]+((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D){0,1} {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}[1-9][0-9]*(e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}([1-9][0-9]*|0)((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D) {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}[0-9]+"."((e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}){0,1}(f|F|d|D) {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}[0-9]+"."(e|E)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}[0-9]+"."/([^..]|"."{3}|[\n]) {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}0(x|X)[0-9a-fA-F]+"."[0-9a-fA-F]*(p|P)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
-{0,1}0(x|X)[0-9a-fA-F]*"."[0-9a-fA-F]+(p|P)(("+"|-){0,1}([1-9][0-9]*|[0])){0,1}(f|F|d|D){0,1} {yylval.str = strdup(yytext);return FLOAT_LITERAL;}
'(\\.|[^'])' {yylval.str = strdup(yytext);return CHAR_LITERAL;}
\"(\\.|[^"\\])*\"   {
                        yylval.str = strdup(yytext);
                        return STRING_LITERAL;
                    }
\"\"\"(\\.|\n|[^"]|\"[^"]|\"\"[^"])*[\n|\r|\r\n](\\.|\n|[^"]|\"[^"]|\"\"[^"])*\"\"\" {
                        yylval.str = strdup(yytext);
                        return TEXT_BLOCK;
                    }
[_]*[_a-zA-Z][_a-zA-Z0-9]* {yylval.str = strdup(yytext);return IDENTIFIER;}
. ;
%%

int yywrap(void){
    return 1;
}