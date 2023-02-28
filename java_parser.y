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
string ti;
vector<vector<string>> toc;
vector<string> k;
int no_chapters = 0, no_sections = 0, no_paragraph = 0, no_sentences = 0, no_words = 0;
int no_declarative = 0, no_exclamatory = 0, no_interrogative = 0;
int p=-1;
%}

%union{
    int num;
    char id;
    char* str;
}

%start T
%token<str> word space number eos eop e punc SECTION colon nl CHAPTER TITLE period exclamatory interrogative
%type<str> isentence sentence ipara para isection section ichapter chapter C ititle title T

%%

T           : title C 
            | T C 
            ;

title       : ititle nl         {ti = $1;}
            | ititle eop        {ti = $1;}
            | title nl
            ;

ititle      : TITLE colon
            | ititle space
            | ititle word
            | ititle punc
            | ititle number
            ;

C           : chapter para  
            | chapter section 
            | C para   
            | C section  
            ;

chapter     : ichapter nl        {no_chapters++; if(k.size()!=0)toc.push_back(k); k.clear(); k.push_back($1)}
            | ichapter eop       {no_chapters++; if(k.size()!=0)toc.push_back(k); k.clear(); k.push_back($1)}
            | chapter nl
            | chapter eop
            ;

ichapter    : CHAPTER isentence colon
            | ichapter space
            | ichapter word
            | ichapter punc
            | ichapter number
            ;

section     : isection nl            {no_sections++; k.push_back($1);}
            | isection eop           {no_sections++; k.push_back($1);}
            | section nl            
            | section eop           
            ;

isection    : SECTION isentence colon      
            | isection space                
            | isection word             
            | isection punc     
            | isection number      
            ;

para        : ipara eop             {no_paragraph++;}
            | para nl               
            | para eop              
            ; 

ipara       : sentence                 
            | ipara space       
            | ipara space sentence      
            ;

sentence    : isentence period                  {no_sentences++; no_declarative++;}
            | isentence exclamatory             {no_sentences++; no_exclamatory++;}
            | isentence interrogative            {no_sentences++; no_interrogative++;}
            ;

isentence   : word                     {no_words++;}
            | number              
            | punc      
            | isentence space       
            | isentence number 
            | isentence punc
            | isentence word           {no_words++;}
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

    toc.push_back(k);

    ti.erase(remove(ti.begin(), ti.end(), '\n'), ti.cend());
    cout << ti << endl;

    cout << "Number of Chapters: " << no_chapters << endl;
    cout << "Number of Sections: " << no_sections << endl;
    cout << "Number of Paragraph: " << no_paragraph << endl;
    cout << "Number of Sentences: " << no_sentences << endl;
    cout << "Number of Words: " << no_words << endl;

    cout << "Number of Declarative Sentences: " << no_declarative << endl;
    cout << "Number of Exclamatory Sentences: " << no_exclamatory << endl;
    cout << "Number of Interrogative Sentences: " << no_interrogative << endl;

    cout << "Table of Contents: " << endl;

    for(int i=0; i<toc.size(); i++)
    {
        for(int j=0; j<toc[i].size(); j++)
        {
            toc[i][j].erase(remove(toc[i][j].begin(), toc[i][j].end(), '\n'), toc[i][j].cend());
            if(j==0)
            cout << toc[i][j] << endl;
            else
            cout << "\t" << toc[i][j] << endl;
        }
    }

	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nFor the Token: %s\nIn Line number:%d\n", s, yytext, yylineno);} 
