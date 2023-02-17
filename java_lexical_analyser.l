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
%}

%%
[/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]|[/][/].*[\n]|[ \t\n\r\f]|[\r][\n] ;
abstract|continue|for|new|switch|assert|default|if|package|synchronized|boolean|do|goto|private|this|break|double|implements|protected|throw|byte|else|import|public|throws|case|enum|instanceof|return|transient|catch|extends|int|short|try|char|final|interface|static|void|class|finally|long|strictfp|volatile|const|float|native|super|while|_ return KEYWORD;
exports|opens|requires|uses|module|permits|sealed|var|non-sealed|provides|to|with|open|record|transitive|yield return KEYWORD;
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
[_]*[_a-zA-Z][_a-zA-Z0-9]* return IDENTIFIER;
[(){};,@]|"["|"]"|"."|"."{3}|:{2} return SEPARATOR;
.  return ERROR;
%%

int yywrap(void){
    return 1;
}

int main(int argc, char** argv){

    if(argc!=3)
    {
        cout << "The syntax for execution is: program input_filename output_filename" << endl;
        return 0;
    }

    FILE *infile = fopen(argv[1], "r");
    ofstream outfile;
    outfile.open(argv[2], ios::trunc);
    if (!infile) {
        cout << "I can't open the file!" << endl;
        return -1;
    }
    yyin = infile;

    map<string, int> tokens;
    vector<string> text;
    vector<string> type;
    vector<int> count;
    
    int token = yylex();
    while(token){

        string t;

        if(token==KEYWORD)
        t="Keyword";
        else if(token==IDENTIFIER)
        t="Identifier";
        else if(token==OPERATOR)
        t="Operator";
        else if(token==SEPARATOR)
        t="Separator";
        else if(token==INT_LITERAL || token==FLOAT_LITERAL || token==BOOL_LITERAL || token==CHAR_LITERAL || token==STRING_LITERAL || token==TEXT_BLOCK || token==NULL_LITERAL)
        t="Literal";
        else
        t="Error";

        if(tokens.find(yytext)==tokens.end())
        {
            tokens[yytext] = text.size();
            text.push_back(yytext);
            type.push_back(t);
            if(t=="Error")
            {
                count.push_back(yylineno);
            }
            else
            count.push_back(1);
        }
        else
        {
            count[tokens[yytext]]++;
        }

        token = yylex();
    }

    outfile << "Lexeme, Token, Count" << endl;

    for(int i=0; i<text.size(); i++)
    {
        if(type[i]!="Error")
        outfile << text[i] << "," << type[i] << "," << count[i] << endl;
        else
        cout << "Unrecognized character: " << text[i] << "in line number: " << count[i] << endl;

    }

    fclose(infile);
    outfile.close();

    return 0;

}