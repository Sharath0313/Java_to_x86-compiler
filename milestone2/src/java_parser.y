%{
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm> 
#include <cstdio>
#include <map>
#include <cstring>
#include <set>
#include <sstream>
using namespace std;

void yyerror (char *s);
extern char* yytext;
extern int yylineno;
extern FILE *yyin;
int yylex();
ofstream outfile;
ofstream fout;
int node = 0,label = 0,variable = 0;
set<string> types1,types2,types3;

struct list{
    char* val;
    int dim;
    char* initializer;
    struct list* next;
    struct list* prev;
} typedef list;

struct symrec{
    char *name,*datatype;
    int lineno,type,dimension;       // 1->localvar 2->class 3->method 4->import 5->package
    list* args;
    bool mod;
} typedef symrec;

symrec create_symrec(char* name, char* datatype, int lineno, int type, int dimension, list* args, bool mod){

    symrec temp;
    temp.name = name;
    temp.datatype = datatype;
    temp.lineno = lineno;
    temp.type = type;
    temp.dimension = dimension;
    temp.args = args;
    temp.mod = mod;

    return temp;

}

struct nlist{
    symrec info;
    struct nlist* next;
    struct nlist* prev;
} typedef nlist;

nlist* create_nlist(char* name, char* datatype, int lineno, int type, int dimension, list* args, bool mod){

    nlist* temp = new nlist;
    symrec t = create_symrec(name, datatype, lineno, type, dimension, args, mod);
    temp->info = t;
    temp->next = NULL;
    temp->prev = NULL;

    return temp;

}

list* create_list(char* val, int dim){

    list* temp = new list;
    temp->prev = NULL;
    temp->next = NULL;
    temp->val = val;
    temp->dim = dim;

    return temp;

}

nlist* find_in_list(nlist*,char* id);
map<int, list*> nt;
map<int, list*> args;
map<int, nlist*> each_symboltable;
map<int, int> parents;
vector<nlist*> symboltables;
map<string, nlist*> classtable;
map<string, nlist*> interfacetable;
nlist* Global = create_nlist("System.out.println", "void", -1, 3, 0, create_list("all",0), true);
nlist* global_tail = Global;
map<string, int> types;
map<int, string> codes;
map<int, sstream> thecode;
map<int, string> exptypes;

void out(nlist* t){
    
    nlist* temp = t;
    while(temp!=NULL){
        cout << temp->info.name << ", " << temp->info.datatype << ", " << temp->info.lineno << ", " << temp->info.type << ", " << temp->info.dimension << endl;
        temp = temp->next;
    }

    return ;

}

nlist* clone(nlist* l, bool super){

    nlist* k = create_nlist("", "", -1, -1, -1, NULL, false);
    nlist* a = l;
    if(a==NULL)return NULL;
    nlist* t = k;
    

    while(a!=NULL){
        if(a->info.mod)
        {
            t->next = create_nlist(a->info.name, a->info.datatype, a->info.lineno, a->info.type, a->info.dimension, a->info.args, a->info.mod);
            t->next->prev = t;
            t = t->next;
            if(super)
            {
                string p = "super.";
                char* z = const_cast<char*>(p.c_str());
                strcat(z,a->info.name);
                t->next = create_nlist(strdup(z), a->info.datatype, a->info.lineno, a->info.type, a->info.dimension, a->info.args, a->info.mod);
                t->next->prev = t;
                t = t->next;
            }
        }
        a = a->next;
    }
    
    return k->next;

}

void push_global(nlist* &nl){
    
    if(nl == NULL)return;

    global_tail->next = nl;
    nl->prev = global_tail;

    while(global_tail->next != NULL)global_tail = global_tail->next;

    return;

}

void pop_global(nlist* &nl){

    if(nl==NULL) return;

    global_tail = nl->prev;
    nl->prev = NULL;
    global_tail->next = NULL;

    return ;

}

void merge(list* &n1, list* n2){

    list* temp = n1;
    if(temp == NULL)
    {
        n1 = n2;
        return ;
    }
    if(n2 == NULL)
    return ;

    while(temp->next!=NULL)temp = temp->next;

    temp->next = n2;
    if(n2 != NULL)
    n2->prev = temp;

    return ;

}

void mergen(nlist* &n1, nlist* n2){

    nlist* temp = n1;
    if(temp == NULL)
    {
        n1 = n2;
        return ;
    }
    if(n2 == NULL)
    return ;

    while(temp->next!=NULL)temp = temp->next;

    temp->next = n2;
    if(n2 != NULL)
    n2->prev = temp;

    return ;

}

nlist* create_st(list* name, list* datatype, int lineno, int type, int dimension, list* args, bool mod){

    if(datatype == NULL || datatype->next != NULL)
    return NULL;

    if(types.find(datatype->val)!=types.end())
    {
        list* temp = name;
        if(find_in_list(global_tail, temp->val)) yyerror("variable with name already exists");
        nlist* k = create_nlist(temp->val, datatype->val, lineno, type, dimension + temp->dim + datatype->dim, args, mod);
        nlist* t = k;
        temp = temp->next;

        while(temp!=NULL)
        {
            if(find_in_list(t,temp->val)) yyerror("variable with name already exists");
            t->next = create_nlist(temp->val, datatype->val, lineno, type, dimension + temp->dim + datatype->dim, args, mod);
            t->next->prev = t;
            t = t->next;
            temp = temp->next;
        }
        return k;
    }
    else if(classtable.find(datatype->val)!=classtable.end())
    {
        nlist* k = clone(classtable[datatype->val], false);
        nlist* temp = k;
        list* t = name;
        nlist* prev = NULL;
        t->val = strcat(t->val,".");
        while(temp!=NULL)
        {
            char *z = strdup(t->val);
            temp->info.name = strcat(z,temp->info.name);
            prev = temp;
            temp = temp->next;
        }
        t = t->next;

        while(t!=NULL)
        {
            temp = prev;
            temp->next = clone(classtable[datatype->val], false);
            temp->next->prev = temp;
            temp = temp->next;
            t->val = strcat(t->val,".");
            while(temp!=NULL)
            {
                char *z = strdup(t->val);
                temp->info.name = strcat(z,temp->info.name);
                prev = temp;
                temp = temp->next;
            }
            t = t->next;
        }

        return k;

    }
    else if(interfacetable.find(datatype->val)!=interfacetable.end())
    {
        nlist* k = clone(interfacetable[datatype->val], false);
        nlist* temp = k;
        list* t = name;
        nlist* prev = NULL;
        t->val = strcat(t->val,".");
        while(temp!=NULL)
        {
            char *z = strdup(t->val);
            temp->info.name = strcat(z,temp->info.name);
            prev = temp;
            temp = temp->next;
        }
        t = t->next;

        while(t!=NULL)
        {
            temp = prev;
            temp->next = clone(interfacetable[datatype->val], false);
            temp->next->prev = temp;
            temp = temp->next;
            t->val = strcat(t->val,".");
            while(temp!=NULL)
            {
                char *z = strdup(t->val);
                temp->info.name = strcat(z,temp->info.name);
                prev = temp;
                temp = temp->next;
            }
            t = t->next;
        }

        return k;

    }
    else if(type == 4 || type == 5)
    {
        list* temp = name;
        nlist* k = create_nlist(temp->val, datatype->val, lineno, type, dimension + temp->dim + datatype->dim, args, mod);
        nlist* t = k;
        temp = temp->next;

        while(temp!=NULL)
        {
            t->next = create_nlist(temp->val, datatype->val, lineno, type, dimension + temp->dim + datatype->dim, args, mod);
            t->next->prev = t;
            t = t->next;
            temp = temp->next;
        }
        types[name->val] = 1;
        return k;
    }
    else
    {
        yyerror("Type not found.");
        return NULL;
    } 
}

nlist* find_in_list(nlist* tail, char* id){
    nlist* t = tail;
    while(t){
        if(!strcmp(t->info.name, id)) return t;
        t = t->prev;
    }
    return NULL;
}

string gen_var() {return "t"+to_string(variable++) ;}
string gen_label() {return "L"+to_string(label++) ;}

void gen_exp_types (int a, int b, int r, char *op){
    string v= gen_var(),extra;
    if(!strcmp(op,"concatenate")) { fout << "\t" << v << ":= " << codes[a] << " "<<op<<" "<< codes[b]<<endl; exptypes[r] = "String";}
    else if(types2.find(exptypes[a])!=types2.end()){
        if(types2.find(exptypes[b])!=types2.end()) {
            fout << "\t" << v << ":= " << codes[a] << " "<<op<<"int "<< codes[b]<<endl;
            exptypes[r] = "int";
        }
        else { extra = gen_var();
            fout << "\t" << extra << " := cast_to_float "<< codes[a] <<endl;
            fout << "\t" << v << ":= " << extra << " "<<op<<"float "<< codes[b]<<endl;
            exptypes[r] = "float";
        }
    }
    else{
        if(types2.find(exptypes[b])!=types2.end()) { extra = gen_var();
            fout << "\t" << extra << " := cast_to_float "<< codes[b] <<endl;
            fout << "\t" << v << ":= " << extra << " "<<op<<"float "<< codes[a]<<endl;
            exptypes[r] = "float";
        }
        else { extra = gen_var();
            fout << "\t" << v << ":= " << codes[a] << " "<<op<<"float "<< codes[b]<<endl;
            exptypes[r] = "float";
        }
    }
    codes[r] = v;
}

%}

%union{
    int num;
    char id;
    char* str;
    bool b;
}

%start START 
%token<str> INTEGRALTYPE FLOATINGPOINTTYPE BOOL_LITERAL ASSIGNMENT_OPERATOR SHIFT RELGL INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL TEXT_BLOCK IDENTIFIER NULL_LITERAL
%token<str> BOOLEAN EXTENDS SUPER INTERFACE PUBLIC PROTECTED PRIVATE ABSTRACT STRINGTYPE
%token<str> STATIC FINAL DEFAULT CLASS IMPLEMENTS THROWS THIS SYNCHRONIZED 
%token<str> VOID SWITCH CONTINUE FOR NEW IF DO BREAK THROW ELSE CASE INSTANCEOF RETURN TRANSIENT 
%token<str> CATCH TRY FINALLY VOLATILE NATIVE WHILE   
%token<str> INC DEC RELAND RELOR RELEQ RELNOTEQ 
%token<str> PACKAGE IMPORT SEMICOLON DOT STAR OSB CSB OCB CCB ONB CNB COMMA COLON PLUS MINUS NEG NOT DIV MOD AND UP OR QM EQ
%type<b>    Modifier Modifiers
%type<num>  START CompilationUnit ImportDeclarations TypeDeclarations PackageDeclaration ImportDeclaration SingleTypeImportDeclaration  
%type<num>  TypeImportOnDemandDeclaration TypeDeclaration Name SingleName MultipleName Type PrimitiveType ReferenceType ClassHeader
%type<num>  NumericType ClassOrInterfaceType ClassType ArrayType ClassDeclaration ClassBody ClassBodyDeclarations InterfaceHeader Super
%type<num>  ClassBodyDeclaration ClassMemberDeclaration FieldDeclaration VariableDeclarators VariableDeclarator VariableDeclaratorId VariableInitializer
%type<num>  MethodDeclaration MethodHeader MethodDeclarator FormalParameterList FormalParameter MethodBody StaticInitializer
%type<num>  ConstructorDeclaration ConstructorDeclarator ConstructorBody ExplicitConstructorInvocation InterfaceDeclaration InterfaceBody
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

START                   : CompilationUnit              {if(each_symboltable[$1]!=NULL){pop_global(each_symboltable[$1]);
                                                        symboltables.push_back(each_symboltable[$1]);
                                                        each_symboltable[$1] = NULL;
                                                        $$ = $1;}}          
                        ;                       

CompilationUnit         : %empty                    {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | PackageDeclaration        {$$ = $1;}                
                        | ImportDeclarations        {$$ = $1;}            
                        | PackageDeclaration ImportDeclarations {$$ = $1;}           
                        | TypeDeclarations          {$$ = $1;}
                        | PackageDeclaration TypeDeclarations   {$$ = $1;}         
                        | ImportDeclarations TypeDeclarations   {$$ = $1;}            
                        | PackageDeclaration ImportDeclarations TypeDeclarations    {$$ = $1;} 
                        ;
ImportDeclarations      : ImportDeclaration                         {$$ = $1;}
                        | ImportDeclarations ImportDeclaration      {$$ = $1;}
                        ;
TypeDeclarations        : TypeDeclaration                           {$$ = $1;}
                        | TypeDeclarations TypeDeclaration          {if(each_symboltable[$1]!=NULL) $$ = $1;
                                                                    else $$ = $2;}     
                        ;
PackageDeclaration      : PACKAGE Name SEMICOLON                    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 5, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);}
                        ;
ImportDeclaration       : SingleTypeImportDeclaration               {$$ = $1;}
                        | TypeImportOnDemandDeclaration             {$$ = $1;}
                        ;
SingleTypeImportDeclaration : IMPORT Name SEMICOLON                 {$$ = node;
                                                                    node++;
                                                                    string temp;
                                                                    string k = nt[$2]->val;
                                                                    for(int i=0; i<k.size(); i++){
                                                                        temp += k[i];
                                                                        if(k[i]=='.') temp = "";
                                                                    }
                                                                    nt[$2]->val = const_cast<char*>(temp.c_str());
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 4, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);}  
                            ;
TypeImportOnDemandDeclaration   : IMPORT Name DOT STAR SEMICOLON    {$$ = node;
                                                                    node++;
                                                                    string temp;
                                                                    string k = nt[$2]->val;
                                                                    for(int i=0; i<k.size(); i++){
                                                                        temp += k[i];
                                                                        if(k[i]=='.') temp = "";
                                                                    }
                                                                    nt[$2]->val = const_cast<char*>(temp.c_str());
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 4, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);}
                                ;
TypeDeclaration         : ClassDeclaration                          {$$ = $1;}
                        | InterfaceDeclaration                      {$$ = $1;}
                        | SEMICOLON                                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;

Literal                 : INT_LITERAL               {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "int";}
                        | FLOAT_LITERAL             {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "float";}
                        | BOOL_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "boolean";}
                        | CHAR_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "char";}
                        | STRING_LITERAL            {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "String";}
                        | NULL_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "";}
                        | TEXT_BLOCK                {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;
                                                    codes[$$] = $1;
                                                    exptypes[$$] = "String";}
                        ;

Name                    : SingleName                    {$$ = $1;}
                        | MultipleName                  {$$ = $1;}
                        ;   
SingleName              : IDENTIFIER                    {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0);
                                                        codes[$$]= $1;}
                        ;
MultipleName            : Name DOT IDENTIFIER           {strcat(nt[$1]->val,$2);
                                                        strcat(nt[$1]->val,$3);
                                                        $$ = $1;
                                                        codes[$$] = nt[$1]->val;} 
                        ;
Modifiers               : STATIC Modifier           {$$ = $2;}
                        | Modifier STATIC           {$$ = $1;}
                        | Modifier                  {$$ = $1;}
                        | STATIC                    {$$ = true;}
                        ;
Modifier                : PUBLIC                    {$$ = true;}
                        | PRIVATE                   {$$ = false;}
Type                    : PrimitiveType                 {$$ = $1;}
                        | ReferenceType                 {$$ = $1;}
                        ;
PrimitiveType           : NumericType                   {$$ = $1;}
                        | BOOLEAN                       {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0); codes[$$] = $1; 
                                                        exptypes[$$] = $1;}
                        | STRINGTYPE                    {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0); codes[$$] = $1;
                                                        exptypes[$$] = $1;}
                        ;
NumericType             : INTEGRALTYPE                  {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0); codes[$$] = $1;
                                                        exptypes[$$] = $1;}
                        | FLOATINGPOINTTYPE             {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0); codes[$$] = $1;
                                                        exptypes[$$] = $1;}
                        
                        ;
ReferenceType           : ClassOrInterfaceType          {$$ = $1;} 
                        | ArrayType                     {$$ = $1;}
                        ;
ClassOrInterfaceType    : Name                          {$$ = $1;
                                                        exptypes[$$] = nt[$1]->val;}                
                        ;
ClassType               : ClassOrInterfaceType          {$$ = $1;}
                        ;
ArrayType               : PrimitiveType OSB CSB                     {nt[$1]->dim++;
                                                                    $$ = $1;} 
                        | Name OSB CSB                              {nt[$1]->dim++;
                                                                    $$ = $1;}
                        | ArrayType OSB CSB                         {nt[$1]->dim++;
                                                                    $$ = $1;} 
                        ;

ClassDeclaration        : ClassHeader ClassBody                             {
                                                                            $$ = $1;
                                                                            if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) {
                                                                                    classtable[each_symboltable[$1]->info.name] = each_symboltable[$2];
                                                                                }
                                                                                else yyerror("Class already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            } 
                        | ClassHeader Super ClassBody                       {$$ = $1;
                                                                            if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) {
                                                                                    classtable[each_symboltable[$1]->info.name] = NULL;
                                                                                    nlist* c1 = clone(classtable[nt[$2]->val], false);
                                                                                    mergen(classtable[each_symboltable[$1]->info.name], c1);
                                                                                    nlist* c2 = clone(each_symboltable[$3], false);
                                                                                    mergen(classtable[each_symboltable[$1]->info.name], c2);
                                                                                }
                                                                                else yyerror("Class already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            else{
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) {
                                                                                    classtable[each_symboltable[$1]->info.name] = each_symboltable[$3];
                                                                                }
                                                                                else yyerror("Class already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            }
                        ;
ClassHeader             : CLASS IDENTIFIER                              {
                                                                        $$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($2, 0),create_list($1, 0), yylineno, 2, 0, NULL, true);
                                                                        push_global(each_symboltable[$$]);}
                        | Modifiers CLASS IDENTIFIER                    {
                                                                        $$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($3, 0),create_list($2, 0), yylineno, 2, 0, NULL, $1);
                                                                        push_global(each_symboltable[$$]);}
                        ;
Super                   : EXTENDS ClassType                             {$$ = node;
                                                                        node++;
                                                                        nt[$$] = nt[$2];
                                                                        if(classtable.find(nt[$2]->val)!=classtable.end()) {
                                                                            nlist* c3 = clone(classtable[nt[$2]->val], true);
                                                                            each_symboltable[$$] = c3;
                                                                            push_global(each_symboltable[$$]);
                                                                        }
                                                                        else yyerror("Class not found");}             
                        ;
ClassBody               : OCB CCB                   {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | OCB ClassBodyDeclarations CCB     {$$ = $2;}             
                        ;
ClassBodyDeclarations   : ClassBodyDeclaration      {$$ = $1;}
                        | ClassBodyDeclarations ClassBodyDeclaration    {$$ = $1;}
                        ;
ClassBodyDeclaration    : ClassMemberDeclaration    {$$ = $1;}
                        | StaticInitializer         {$$ = $1;}
                        | ConstructorDeclaration    {$$ = $1;}
                        ;
ClassMemberDeclaration  : FieldDeclaration          {$$ = $1;}
                        | MethodDeclaration         {$$ = $1;}
                        ;
FieldDeclaration        : Type VariableDeclarators SEMICOLON        {
                                                                    $$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);}
                        | Modifiers Type VariableDeclarators SEMICOLON  {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$2], yylineno, 1, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);  }
                        ;
VariableDeclarators     : VariableDeclarator                            {$$ = $1;}
                        | VariableDeclarators COMMA VariableDeclarator  {merge(nt[$1],nt[$3]);
                                                                        $$ = $1;}
                        ;
VariableDeclarator      : VariableDeclaratorId                          {$$ = $1;}
                        | VariableDeclaratorId EQ VariableInitializer   {$$ = $1;}
                        ;
VariableDeclaratorId    : IDENTIFIER                                    {$$ = node;
                                                                        node++;
                                                                        nt[$$] = create_list($1, 0);}
                        | VariableDeclaratorId OSB CSB                  {nt[$1]->dim++;
                                                                        $$ = $1;}
                        ;
VariableInitializer     : Expression
                        | ArrayInitializer
                        ;
MethodDeclaration       : MethodHeader MethodBody                   {$$ = $1;}
                        ;
MethodHeader            : Type MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];
                                                                    if(each_symboltable[$2]) $$ = $2;}          
                        | Modifiers Type MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$1], yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$3];
                                                                    if(each_symboltable[$3]!=NULL) $$ = $3;}
                        | VOID MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];
                                                                    if(each_symboltable[$2]) $$ = $2;}
                        | Modifiers VOID MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], create_list($2, 0), yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$3];
                                                                    if(each_symboltable[$3]!=NULL) $$ = $3;}
                        ;
MethodDeclarator        : SingleName ONB CNB                            {$$ = $1;}
                        | SingleName ONB FormalParameterList CNB        {$$ = $3;
                                                                        list* k = nt[$3];
                                                                        nt[$$] = nt[$1];
                                                                        args[$$] = k;}
                        | MethodDeclarator OSB CSB                      {$$ = $1;}
                        ;
FormalParameterList     : FormalParameter                               {$$ = $1;}
                        | FormalParameterList COMMA FormalParameter     {merge(nt[$1],nt[$3]);
                                                                        $$ = $1;}
                        ;
FormalParameter         : Type VariableDeclaratorId                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    nt[$$] = nt[$1];}            
                        ;
MethodBody              : Block                     {$$ = $1;}
                        | SEMICOLON                 {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        ;           
StaticInitializer       : STATIC Block              {$$ = $2;}
                        ;
ConstructorDeclaration  : ConstructorDeclarator ConstructorBody         {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$1], create_list("Constructor", 0), yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$1];}
                        | Modifiers ConstructorDeclarator ConstructorBody   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list("Constructor", 0), yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];}
                        ;
ConstructorDeclarator   : SingleName ONB CNB                        {$$ = $1;}   
                        | SingleName ONB FormalParameterList CNB    {$$ = $1;
                                                                    args[$$] = nt[$3];} 
                        ;   
ConstructorBody         : OCB CCB                   {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | OCB ExplicitConstructorInvocation CCB             {$$ = node;
                                                                            node++;
                                                                            each_symboltable[$$] = NULL;}
                        | OCB BlockStatements CCB                           {if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;
                                                                                }
                                                                            }         
                        | OCB ExplicitConstructorInvocation BlockStatements CCB {if(each_symboltable[$3]!=NULL){
                                                                                    pop_global(each_symboltable[$3]);
                                                                                    symboltables.push_back(each_symboltable[$3]);
                                                                                    each_symboltable[$3] = NULL;
                                                                                    $$ = $3;
                                                                                    }
                                                                                }
                        ;
ExplicitConstructorInvocation   : THIS ONB CNB SEMICOLON            
                                | THIS ONB ArgumentList CNB SEMICOLON
                                | SUPER ONB CNB SEMICOLON
                                | SUPER ONB ArgumentList CNB SEMICOLON
                                ;

InterfaceDeclaration    : InterfaceHeader InterfaceBody                     {$$ = $1;
                                                                            if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                if(interfacetable.find(each_symboltable[$1]->info.name)==interfacetable.end()) {
                                                                                    interfacetable[each_symboltable[$1]->info.name] = each_symboltable[$2];
                                                                                }
                                                                                else yyerror("Interface already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            }                   
                        ;
InterfaceHeader         : INTERFACE IDENTIFIER                          {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($2, 0),create_list($1, 0), yylineno, 2, 0, NULL, true);
                                                                        push_global(each_symboltable[$$]);}
                        | Modifiers INTERFACE IDENTIFIER                {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($3, 0),create_list($2, 0), yylineno, 2, 0, NULL, $1);
                                                                        push_global(each_symboltable[$$]);}
                        ;
InterfaceBody           : OCB CCB                                   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;}
                        | OCB InterfaceMemberDeclarations CCB               {$$ = $2;}          
                        ;
InterfaceMemberDeclarations : InterfaceMemberDeclaration                                {$$ = $1;}
                            | InterfaceMemberDeclarations InterfaceMemberDeclaration    {$$ = $1;}
                            ;
InterfaceMemberDeclaration  : ConstantDeclaration                       {$$ = $1;}
                            | AbstractMethodDeclaration                 {$$ = $1;}
                            ;
ConstantDeclaration     : FieldDeclaration                              {$$ = $1;}
                        ;   
AbstractMethodDeclaration   : MethodHeader SEMICOLON                    {$$ = $1;}
                            ;

ArrayInitializer        : OCB CCB
                        | OCB VariableInitializers CCB
                        | OCB COMMA CCB
                        | OCB VariableInitializers COMMA CCB
                        ;
VariableInitializers    : VariableInitializer
                        | VariableInitializers COMMA VariableInitializer
                        ;

Block                   : OCB CCB                                           {$$ = node;
                                                                            node++;
                                                                            each_symboltable[$$] = NULL;}
                        | OCB BlockStatements CCB                           {if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;
                                                                                }
                                                                            }
                        ;
BlockStatements         : BlockStatement                                    {$$ = $1;}
                        | BlockStatements BlockStatement                    {if(each_symboltable[$1]!=NULL) $$ = $1;
                                                                            else $$ = $2;}
                        ;
BlockStatement          : LocalVariableDeclarationStatement                 {$$ = $1;}
                        | Statement                                         {$$ = $1;}               
                        ;
LocalVariableDeclarationStatement   : LocalVariableDeclaration SEMICOLON    {$$ = $1; }
                                    ;
LocalVariableDeclaration    : Type VariableDeclarators              {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);  }   
                            ;
Statement               : StatementWithoutTrailingSubstatement      {$$ = $1;}   
                        | LabeledStatement                          {$$ = $1;}
                        | IfThenStatement                           {$$ = $1;}
                        | IfThenElseStatement                       {$$ = $1;}
                        | WhileStatement                            {$$ = $1;}
                        | ForStatement                              {$$ = $1;}
                        ;
StatementNoShortIf      : StatementWithoutTrailingSubstatement      {$$ = $1;}
                        | LabeledStatementNoShortIf                 {$$ = $1;}
                        | IfThenElseStatementNoShortIf              {$$ = $1;}
                        | WhileStatementNoShortIf                   {$$ = $1;}
                        | ForStatementNoShortIf                     {$$ = $1;}
                        ;
StatementWithoutTrailingSubstatement    : Block                     {$$ = $1;}  
                                        | EmptyStatement            {$$ = $1;}
                                        | ExpressionStatement       {$$ = $1;}
                                        | SwitchStatement           {$$ = $1;}
                                        | DoStatement               {$$ = $1;}
                                        | BreakStatement            {$$ = $1;}
                                        | ContinueStatement         {$$ = $1;}
                                        | ReturnStatement           {$$ = $1;}
                                        | SynchronizedStatement     {$$ = $1;}
                                        | ThrowStatement            {$$ = $1;}
                                        | TryStatement              {$$ = $1;}
                                        ;
EmptyStatement          : SEMICOLON                                         {$$ = node;
                                                                            node++;
                                                                            each_symboltable[$$] = NULL;}            
                        ;
LabeledStatement        : IDENTIFIER COLON Statement                        {$$ = $3;} 
                        ;
LabeledStatementNoShortIf   : IDENTIFIER COLON StatementNoShortIf           {$$ = $3;} 
                            ;
ExpressionStatement     : StatementExpression SEMICOLON                     {$$ = $1;}
                        ;
StatementExpression     : Assignment                                        {$$ = $1;}
                        | PreIncrementExpression                            {$$ = $1;}
                        | PreDecrementExpression                            {$$ = $1;}
                        | PostIncrementExpression                           {$$ = $1;}
                        | PostDecrementExpression                           {$$ = $1;}
                        | MethodInvocation                                  {$$ = $1;}
                        | ClassInstanceCreationExpression                   {$$ = $1;}
                        ;
IfThenStatement         : IF ONB Expression CNB Statement                   {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                            }
                        ;
IfThenElseStatement     : IF ONB Expression CNB StatementNoShortIf ELSE Statement   {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                            }
                        ;
IfThenElseStatementNoShortIf    : IF ONB Expression CNB StatementNoShortIf ELSE StatementNoShortIf  {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                            }
                                ;
SwitchStatement         : SWITCH ONB Expression CNB SwitchBlock     {$$ = $5;}
                        ;
SwitchBlock             : OCB CCB                                   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;}  
                        | OCB SwitchLabels CCB                      {$$ = $2;}
                        | OCB SwitchBlockStatementGroups CCB                {if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;
                                                                                }
                                                                            }
                        | OCB SwitchBlockStatementGroups SwitchLabels CCB   {if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;
                                                                                }
                                                                            }
                        ;
SwitchBlockStatementGroups  : SwitchBlockStatementGroup             {$$ = $1;}    
                            | SwitchBlockStatementGroups SwitchBlockStatementGroup  {if(each_symboltable[$1]!=NULL) $$=$1;
                                                                            else $$ = $2;}
                            ;
SwitchBlockStatementGroup   : SwitchLabels BlockStatements                  {$$ = $2;}
                            ;
SwitchLabels            : SwitchLabel                               {$$ = $1;}
                        | SwitchLabels SwitchLabel                  {if(each_symboltable[$1]!=NULL) $$=$1;
                                                                    else $$ = $2;}
                        ;
SwitchLabel             : CASE ConstantExpression COLON             {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | DEFAULT COLON                             {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
WhileStatement          : WHILE ONB Expression CNB Statement                {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                            }   
                        ;
WhileStatementNoShortIf : WHILE ONB Expression CNB StatementNoShortIf       {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                            }
                        ;
DoStatement             : DO Statement WHILE ONB Expression CNB SEMICOLON   {if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;
                                                                                }
                                                                            }
                        ;
ForStatement            : FOR ONB SEMICOLON SEMICOLON CNB Statement         {if(each_symboltable[$6]!=NULL){
                                                                                pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;
                                                                                }
                                                                            }      
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB Statement {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB Statement  {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                                }
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB Statement  {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB Statement   {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                                }
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB Statement   {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {if(each_symboltable[$8]!=NULL){
                                                                                pop_global(each_symboltable[$8]);
                                                                                symboltables.push_back(each_symboltable[$8]);
                                                                                each_symboltable[$8] = NULL;
                                                                                $$ = $8;
                                                                                }
                                                                                }   
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        ;
ForStatementNoShortIf   : FOR ONB SEMICOLON SEMICOLON CNB StatementNoShortIf    {if(each_symboltable[$6]!=NULL){
                                                                                pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;
                                                                                }
                                                                            }
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB StatementNoShortIf    {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                            }
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf  {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                            }
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf  {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {if(each_symboltable[$8]!=NULL){
                                                                                pop_global(each_symboltable[$8]);
                                                                                symboltables.push_back(each_symboltable[$8]);
                                                                                each_symboltable[$8] = NULL;
                                                                                $$ = $8;
                                                                                }
                                                                            }
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        ;
ForInit                 : StatementExpressionList           {$$ = $1;}
                        | LocalVariableDeclaration          {$$ = $1;}
                        ;
ForUpdate               : StatementExpressionList           {$$ = $1;}
                        ;
StatementExpressionList : StatementExpression               {$$ = $1;}
                        | StatementExpressionList COMMA StatementExpression         {$$ = $1;}
                        ;
BreakStatement          : BREAK SEMICOLON                           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;}              
                        | BREAK IDENTIFIER  SEMICOLON               {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
ContinueStatement       : CONTINUE SEMICOLON                        {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | CONTINUE IDENTIFIER SEMICOLON             {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
ReturnStatement         : RETURN SEMICOLON                          {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | RETURN Expression SEMICOLON               {$$ = $2;} 
                        ;
ThrowStatement          : THROW Expression SEMICOLON                {$$ = $2;} 
                        ;
SynchronizedStatement   : SYNCHRONIZED  ONB Expression CNB Block    {$$ = $5;} 
                        ;
TryStatement            : TRY Block Catches                         {$$ = $2;} 
                        | TRY Block Finally                         {$$ = $2;} 
                        | TRY Block Catches Finally                 {$$ = $2;} 
                        ;
Catches                 : CatchClause                               {$$ = $1;} 
                        | Catches CatchClause                       {$$ = $1;} 
                        ;
CatchClause             : CATCH ONB FormalParameter CNB Block       {$$ = $5;} 
                        ;
Finally                 : FINALLY Block                             {$$ = $2;} 
                        ;

Primary                 : PrimaryNoNewArray                         {$$ = $1;}
                        | ArrayCreationExpression                   {$$ = $1;}
                        ;
PrimaryNoNewArray       : Literal                                   {$$ = $1;}
                        | THIS                                      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | ONB Expression CNB                        {$$ = $2;}
                        | ClassInstanceCreationExpression           {$$ = $1;}
                        | FieldAccess                               {$$ = $1;}
                        | MethodInvocation                          {$$ = $1;}
                        | ArrayAccess                               {$$ = $1;}
                        ;
ClassInstanceCreationExpression : NEW ClassType ONB CNB             {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;}  
                                | NEW ClassType ONB ArgumentList CNB    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                                ;
ArgumentList            : Expression                                
                        | ArgumentList COMMA Expression             
                        ;
ArrayCreationExpression : NEW PrimitiveType DimExprs                {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | NEW PrimitiveType DimExprs Dims           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | NEW ClassOrInterfaceType DimExprs         {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | NEW ClassOrInterfaceType DimExprs Dims    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
DimExprs                : DimExpr
                        | DimExprs DimExpr
                        ;
DimExpr                 : OSB Expression CSB
                        ;
Dims                    : OSB CSB
                        | Dims OSB CSB
                        ;   
FieldAccess             : Primary DOT IDENTIFIER                    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | SUPER DOT IDENTIFIER                      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;   
MethodInvocation        : Name ONB CNB                              {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | Name ONB ArgumentList CNB                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | Primary DOT IDENTIFIER ONB CNB            {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | Primary DOT IDENTIFIER ONB ArgumentList CNB   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | SUPER DOT IDENTIFIER ONB CNB              {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | SUPER DOT IDENTIFIER ONB ArgumentList CNB {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
ArrayAccess             : Name OSB Expression CSB
                        | PrimaryNoNewArray OSB Expression CSB
                        ;
PostfixExpression       : Primary                                   {$$=$1;}
                        | Name                                      {$$=$1;
                                                                     nlist *q = find_in_list(global_tail,nt[$1]->val);
                                                                    if(!q) yyerror("variable not declared in this scope");
                                                                    exptypes[$$] = q->info.datatype;
                                                                    }
                        | PostIncrementExpression                   {$$=$1;}
                        | PostDecrementExpression                   {$$=$1;}
                        ;
PostIncrementExpression : PostfixExpression INC                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1]) != types1.end()){
                                                                    string v= gen_var();
                                                                    fout<<"\t"<<v<<":="<<codes[$1]<<endl;
                                                                    fout<<"\t"<<codes[$1]<<":= "<<codes[$1]<<" + 1"<<endl;
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$1];
                                                                    }
                                                                    else{
                                                                        yyerror("incompatible operand types for ++");
                                                                    }
                                                                    } 
                        ;   
PostDecrementExpression : PostfixExpression DEC                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1]) != types1.end()){
                                                                    string v= gen_var();
                                                                    fout<<"\t"<<v<<":="<<codes[$1]<<endl;
                                                                    fout<<"\t"<<codes[$1]<<":= "<<codes[$1]<<" - 1"<<endl;
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$1];
                                                                        }
                                                                        else{
                                                                        yyerror("incompatible operand types for --");
                                                                    }
                                                                    } 
                        ;
UnaryExpression         : PreIncrementExpression                    {$$ = $1;}
                        | PreDecrementExpression                    {$$ = $1;}
                        | PLUS UnaryExpression                      {$$ = node; node++; 
                                                                        if(types1.find(exptypes[$2]) != types1.end())
                                                                        {
                                                                            if(exptypes[$2]=="long"||exptypes[$2]=="char") exptypes[$$] = "int";
                                                                            else exptypes[$$] = exptypes[$2];
                                                                        }
                                                                        else yyerror("incompatible operand type for unary +");
                                                                    }
                        | MINUS UnaryExpression                     {   $$ = node; node++;
                                                                        if(types1.find(exptypes[$2]) != types1.end()){
                                                                        string v= gen_var();
                                                                        fout << "\t"<<v<<":= "<<" -"<<codes[$2]<<endl;
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$2];
                                                                        if(exptypes[$2]=="long"||exptypes[$2]=="char") exptypes[$$] = "int";
                                                                        }
                                                                        else yyerror("incompatible operand type for unary -");
                                                                    }
                        | UnaryExpressionNotPlusMinus               {$$ = $1;}
                        ;
PreIncrementExpression  : INC UnaryExpression                       {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$2]) != types1.end()){
                                                                        fout << "\t"<<codes[$2]<<":= "<<codes[$2]<<" + 1"<<endl;
                                                                        codes[$$] = codes[$2];
                                                                        exptypes[$$] = exptypes[$2];
                                                                    } 
                                                                    else yyerror("incompatible operand type for ++");
                                                                    } 
                        ;
PreDecrementExpression  : DEC UnaryExpression                       {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$2]) != types1.end()){
                                                                        fout << "\t"<<codes[$2]<<":= "<<codes[$2]<<" - 1"<<endl;
                                                                        codes[$$] = codes[$2];
                                                                        exptypes[$$] = exptypes[$2];
                                                                    }
                                                                    else yyerror("incompatible operand type for --");
                                                                    } 
                        ;
UnaryExpressionNotPlusMinus : PostfixExpression         {$$ = $1;}
                            | NEG UnaryExpression       {   $$ = node; node++;
                                                            if(types2.find(exptypes[$2]) == types2.end()) yyerror("incompatible operand type");
                                                                        string v= gen_var();
                                                                        fout << "\t"<<v<<":= "<<"~ "<<codes[$2]<<endl;
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$2];
                                                                        }
                            | NOT UnaryExpression       {   $$ = node; node++;
                                                            if(exptypes[$2]!= "boolean") yyerror("incompatible operand type");
                                                                        string v= gen_var();
                                                                        fout << "\t"<<v<<":= "<<"! "<<codes[$2]<<endl;
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$2];
                                                                        }
                            | CastExpression            {$$ = $1;}
                            ;
CastExpression          : ONB PrimitiveType CNB UnaryExpression         {   $$ = node; node++; //cout<<"cout"<<exptypes[$2]<<" 4"<<exptypes[$4];
                                                                        if(types1.find(exptypes[$2]) != types1.end()){
                                                                            if(types1.find(exptypes[$4]) != types1.end()){
                                                                        string v= gen_var();
                                                                        fout << "\t"<<v<<":= "<<"cast_to_"<<codes[$2]<<" "<<codes[$4]<<endl;
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$2];
                                                                            }else yyerror("conversion not possible");
                                                                            }
                                                                            else yyerror("conversion not possible");
                                                                        }
                        | ONB PrimitiveType Dims CNB UnaryExpression    
                        | ONB Expression CNB UnaryExpressionNotPlusMinus
                        | ONB Name Dims CNB UnaryExpressionNotPlusMinus
                        ;
MultiplicativeExpression    : UnaryExpression                                   {$$ = $1;}
                            | MultiplicativeExpression STAR UnaryExpression     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end())
                                                                        yyerror("incompatible operand types for *");
                                                                    gen_exp_types($1,$3,$$,$2);
                                                                    } 
                            | MultiplicativeExpression DIV UnaryExpression      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end())
                                                                        yyerror("incompatible operand types for /");
                                                                    gen_exp_types($1,$3,$$,$2);
                                                                    } 
                            | MultiplicativeExpression MOD UnaryExpression      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end())
                                                                        yyerror("incompatible operand types for %");
                                                                    gen_exp_types($1,$3,$$,$2);
                                                                    } 
                            ;
AdditiveExpression      : MultiplicativeExpression                          {$$ = $1;}
                        | AdditiveExpression PLUS MultiplicativeExpression   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end()){
                                                                        if(exptypes[$1]== "String" && exptypes[$3]== "String") gen_exp_types($1,$3,$$,"concatenate");
                                                                        else yyerror("incompatible operand types for +");}
                                                                    else gen_exp_types($1,$3,$$,$2);
                                                                    } 
                        | AdditiveExpression MINUS MultiplicativeExpression     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end())
                                                                        yyerror("incompatible operand types for -");
                                                                    gen_exp_types($1,$3,$$,$2);
                                                                    } 
                        ;
ShiftExpression         : AdditiveExpression                            {$$ = $1;}
                        | ShiftExpression SHIFT AdditiveExpression      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end())
                                                                        yyerror("incompatible operand types for SHIFT");
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":="  << codes[$1] <<" "<<$2<<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "int";
                                                                    } 
                        ;
RelationalExpression    : ShiftExpression                               {$$=$1;}
                        | RelationalExpression RELGL ShiftExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end())
                                                                        yyerror("incompatible operand types for relational operators");
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        | RelationalExpression INSTANCEOF ReferenceType   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1]) != types1.end() || types1.find(exptypes[$3]) != types1.end()) 
                                                                        yyerror("incompatible operand types for instanceof");
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":=" << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        ;
EqualityExpression      : RelationalExpression                              {$$ = $1;}
                        | EqualityExpression RELEQ RelationalExpression     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end()){
                                                                        if(exptypes[$1]== "String" && exptypes[$3]== "String");
                                                                        else yyerror("incompatible operand types for ==");}
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " = " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        | EqualityExpression RELNOTEQ RelationalExpression  {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end()){
                                                                        if(exptypes[$1]== "String" && exptypes[$3]== "String");
                                                                        else yyerror("incompatible operand types for !=");}
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        ;
AndExpression           : EqualityExpression                        {$$ = $1;}
                        | AndExpression AND EqualityExpression      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    exptypes[$$] = "int";
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end()){
                                                                        if(exptypes[$1]== "boolean" && exptypes[$3]== "boolean") exptypes[$$] = "boolean";
                                                                        else yyerror("incompatible operand types for &");}
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    } 
                        ;
ExclusiveOrExpression   : AndExpression                             {$$ = $1;}
                        | ExclusiveOrExpression UP AndExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    exptypes[$$] = "int";
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end()){
                                                                        if(exptypes[$1]== "boolean" && exptypes[$3]== "boolean") exptypes[$$] = "boolean";
                                                                        else yyerror("incompatible operand types for ^");}
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    } 
                        ;
InclusiveOrExpression   : ExclusiveOrExpression                     {$$ =$1;}
                        | InclusiveOrExpression OR ExclusiveOrExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    exptypes[$$] = "int";
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end()){
                                                                        if(exptypes[$1]== "boolean" && exptypes[$3]== "boolean") exptypes[$$] = "boolean";
                                                                        else yyerror("incompatible operand types for |");}
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    } 
                        ;
ConditionalAndExpression    : InclusiveOrExpression                 {$$ = $1;}
                            | ConditionalAndExpression RELAND InclusiveOrExpression {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(exptypes[$1]!= "boolean" || exptypes[$3]!= "boolean") 
                                                                        yyerror("incompatible operand types for &&");
                                                                    exptypes[$$] = "boolean";
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    } 
                            ;
ConditionalOrExpression : ConditionalAndExpression                                          {$$ = $1;}
                        | ConditionalOrExpression RELOR ConditionalAndExpression            {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL; 
                                                                    if(exptypes[$1]!= "boolean" || exptypes[$3]!= "boolean")
                                                                        yyerror("incompatible operand types for ||");
                                                                    exptypes[$$] = "boolean";
                                                                    string v= gen_var();
                                                                    fout << "\t" << v << ":= " << codes[$1] << " "<< $2 <<" " << codes[$3]<<endl;
                                                                    codes[$$] = v;
                                                                    } 
                        ;
ConditionalExpression   : ConditionalOrExpression                                           {$$ = $1;}
                        | ConditionalOrExpression QM Expression COLON ConditionalExpression {   string t = gen_label(), f= gen_label(), v= gen_var();
                                                                                                fout<<"\t"<<"if "<<codes[$1]<<" goto "<<t<<endl;
                                                                                                fout<<"\t"<<v<<":= "<<codes[$5]<<endl;
                                                                                                fout<<"\t"<<"goto "<<f<<endl;
                                                                                                fout<<t<<":\n\t"<<v<<":= "<<codes[$3]<<endl;
                                                                                                fout<<f<<":\n";
                                                                                                $$ = node; node++;
                                                                                                codes[$$] = v;
                                                                                                exptypes[$$] = "int";
                                                                                            }
                        ;
AssignmentExpression    : ConditionalExpression         {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$] = codes[$1]; exptypes[$$] = exptypes[$1];
                                                                    } 
                        | Assignment                    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$] = codes[$1]; exptypes[$$] = exptypes[$1];} 
                        ;
Assignment              : LeftHandSide Assignment_Operators AssignmentExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types2.find(exptypes[$1])!=types2.end() && types2.find(exptypes[$3])!=types2.end()) 
                                                                    {
                                                                         if(codes[$2]== "=") fout << "\t" << codes[$1] << " := " << codes[$3]<<endl;
                                                                         else if(codes[$2] != "&=") fout << "\t" << codes[$1] << " := " << codes[$1]<<" "<<codes[$2][0]<<"int "<<codes[$3]<<endl;
                                                                         else fout << "\t" << codes[$1] << " := " << codes[$1]<<" "<<codes[$2][0]<<" "<<codes[$3]<<endl;
                                                                    }
                                                                    else if(types3.find(exptypes[$1])!=types3.end() && types3.find(exptypes[$3])!=types3.end()) 
                                                                    {
                                                                        if(codes[$2] == "&=") yyerror("incompatible operand types");
                                                                        else if(codes[$2]== "=") fout << "\t" << codes[$1] << " := " << codes[$3]<<endl;
                                                                         else fout << "\t" << codes[$1] << " := " << codes[$1]<<" "<<codes[$2][0]<<"float "<<codes[$3]<<endl;
                                                                    }
                                                                    else if(exptypes[$1]==exptypes[$3]){ 
                                                                        if(codes[$2] == "&=" && exptypes[$1]=="boolean") fout << "\t" << codes[$1] << " := " << codes[$1]<<" "<<codes[$2][0]<<" "<<codes[$3]<<endl;
                                                                        else if(codes[$2]== "=") fout << "\t" << codes[$1] << " := " << codes[$3]<<endl;
                                                                         else yyerror("incompatible types for assignment");
                                                                    }
                                                                    else if(types3.find(exptypes[$1])!=types3.end() && types2.find(exptypes[$3])!=types2.end()){
                                                                        if(codes[$2]== "=") fout << "\t" << codes[$1] << " := cast_to_float " << codes[$3]<<endl;
                                                                        else {
                                                                            if(codes[$2] == "&=") yyerror("incompatible operand types");
                                                                            string v= gen_var();
                                                                            fout << "\t" << v << " := cast_to_float " << codes[$3]<<endl;
                                                                            fout << "\t" << codes[$1] << " := " << codes[$1]<<" "<<codes[$2][0]<<"float "<<v<<endl;
                                                                        }
                                                                    }
                                                                    else yyerror("incompatible types for assignment (can also be lossy decomposition)");
                                                                    codes[$$] = codes[$1]; exptypes[$$] = exptypes[$1];
                                                                    } 
                        ;
Assignment_Operators    : ASSIGNMENT_OPERATOR                       {$$ = node; node++;
                                                                    codes[$$] = $1;
                                                                    }
                        | EQ                                       {$$ = node; node++;
                                                                    codes[$$] = $1;
                                                                    }
                        ;
LeftHandSide            : Name                                     {$$ = $1; // cout<<"variabel="<<nt[$1]->val<<endl;
                                                                    nlist *q = find_in_list(global_tail,nt[$1]->val);
                                                                    if(!q) yyerror("variable not declared in this scope");
                                                                    exptypes[$$] = q->info.datatype;
                                                                    }
                        | FieldAccess                              
                        | ArrayAccess
                        ;
Expression              : AssignmentExpression                      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$]=codes[$1]; exptypes[$$] = exptypes[$1];} 
                        ;
ConstantExpression      : Expression                                {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$]=codes[$1]; exptypes[$$] = exptypes[$1];} 
                        ;

%%                    


int main (int argc, char** argv) {
    fout.open("output.3ac");
    types["int"] = 1;   types1.insert("int");           types2.insert("int");
    types["long"] = 1;  types1.insert("long");          types2.insert("long"); 
    types["char"] = 1;  types1.insert("char");          types2.insert("char");
    types["float"] = 1;     types1.insert("float");     types3.insert("float");
    types["double"] = 1;    types1.insert("double");    types3.insert("double");
    types["String"] = 1;
    types["class"] = 1;
    types["interface"] = 1;
    types["void"] = 1;
    types["boolean"] = 1;

    if(argc!=3)
    {
        cout << "The syntax for execution is: program input_filename output_filename" << endl;
        return 0;
    }

    FILE *infile = fopen(argv[1], "r");
    outfile.open(argv[2], ios::trunc);
    
    if (!infile) {
        cout << "I can't open the file!" << endl;
        return -1;
    }
    yyin = infile;
    yyparse();
    fclose(infile);

    symboltables.push_back(Global);

    outfile << "Name, " << "DataType, " << "LineNO, " << "Type, " << "ArgumentsOrDimensions" << endl << endl;

    for(int i=0; i<symboltables.size(); i++)
    {
        nlist* temp = symboltables[i];
        while(temp!=NULL)
        {
            outfile << temp->info.name << ", " << temp->info.datatype << ", " << temp->info.lineno << ", " << temp->info.type << ", " << temp->info.dimension << ", ARGS: ";
            list* a = temp->info.args;
            if(a!=NULL)
            {
                outfile << a->val << "(" << a->dim << ")";
                a = a->next;
                while(a!=NULL)
                {
                    outfile << ", " << a->val << "(" << a->dim << ")";
                    a = a->next;
                }
            }
            outfile << endl;
            temp = temp->next;
        }
        outfile << endl; 
    }
    //fout << "System.out.println:\n\tprint()"
    outfile.close();
    fout.close();
	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nIn Line number:%d\n", s, yylineno); exit(0);}