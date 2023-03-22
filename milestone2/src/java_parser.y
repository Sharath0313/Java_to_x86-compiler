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

struct context{
    string Entry, Exit;
}; vector<context> currcontext;

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
map<string, string> parents;
vector<nlist*> symboltables;
map<string, nlist*> classtable;
map<string, nlist*> interfacetable;
nlist* Global = create_nlist("System.out.println", "void", -1, 3, 0, create_list("all",0), true);
nlist* pglobal = create_nlist("", "none", -1, -1, -1, NULL, false);
nlist* pglobal_tail = pglobal;
nlist* global_tail = Global;
map<string, int> types;
map<int, string> codes;
map<int, string> thecode;
map<int, string> exptypes;
map<int, string> identifier;
vector<string> classdec;

void out(nlist* t){
    
    nlist* temp = t;
    while(temp!=NULL){
        cout << temp->info.name << ", " << temp->info.datatype << ", " << temp->info.lineno << ", " << temp->info.type << ", " << temp->info.dimension << "\n";
        temp = temp->next;
    }
    cout << "\n";

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

void push_pglobal(nlist* &nl){
    
    if(nl == NULL)return;

    pglobal_tail->next = nl;
    nl->prev = pglobal_tail;

    while(pglobal_tail->next != NULL)pglobal_tail = pglobal_tail->next;

    return;

}

void pop_global(nlist* &nl){

    if(nl==NULL) return;

    global_tail = nl->prev;
    nl->prev = NULL;
    global_tail->next = NULL;

    return ;

}

void pop_pglobal(nlist* &nl){

    if(nl==NULL) return;

    pglobal_tail = nl->prev;
    nl->prev = NULL;
    pglobal_tail->next = NULL;

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
        list* t1 = name;
        if(find_in_list(global_tail, t1->val)) yyerror("variable with name already exists");
        nlist* k1 = create_nlist(t1->val, datatype->val, lineno, type, dimension + t1->dim + datatype->dim, args, mod);
        nlist* t2 = k1;
        t1 = t1->next;

        while(t1!=NULL)
        {
            if(find_in_list(t2,t1->val)) yyerror("variable with name already exists");
            t2->next = create_nlist(t1->val, datatype->val, lineno, type, dimension + t1->dim + datatype->dim, args, mod);
            t2->next->prev = t2;
            t2 = t2->next;
            t1 = t1->next;
        }

        if(datatype->dim==0)
        {
            list* t = name;
            nlist* k = NULL;
            nlist* temp;
            nlist* prev = NULL;
            while(t!=NULL && k==NULL)
            {
                if(t->dim==0)
                {
                    k = clone(classtable[datatype->val], false);
                    temp = k;

                    char* z = strdup(t->val);
                    z = strcat(z,".");
                    while(temp!=NULL)
                    {
                        temp->info.name = strcat(strdup(z),temp->info.name);
                        prev = temp;
                        temp = temp->next;
                    }
                }
                t = t->next;
            }

            while(t!=NULL && k!=NULL)
            {
                if(t->dim == 0)
                {
                    temp = prev;
                    temp->next = clone(classtable[datatype->val], false);
                    temp->next->prev = temp;
                    temp = temp->next;
                    char* z = strdup(t->val);
                    z = strcat(z,".");
                    while(temp!=NULL)
                    {
                        temp->info.name = strcat(strdup(z),temp->info.name);
                        prev = temp;
                        temp = temp->next;
                    }
                }
                t = t->next;
            }

            if(k!=NULL)
            {
                t2->next = k;
                k->prev = t2;
            }
        }

        return k1;

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
    thecode[r] = thecode[a] + thecode[b];
    if(!strcmp(op,"concatenate")) { thecode[r] += "\t" + v + ":= " + codes[a] + " " + op + " " + codes[b] + "\n"; exptypes[r] = "String";}
    else if(types2.find(exptypes[a])!=types2.end()){
        if(types2.find(exptypes[b])!=types2.end()) {
            thecode[r] += "\t" + v + ":= " + codes[a] + " "+op+"int "+ codes[b]+"\n";
            exptypes[r] = "int";
        }
        else { extra = gen_var();
            thecode[r] += "\t" + extra + " := cast_to_float "+ codes[a] +"\n";
            thecode[r] += "\t" + v + ":= " + extra + " "+op+"float "+ codes[b]+"\n";
            exptypes[r] = "float";
        }
    }
    else{
        if(types2.find(exptypes[b])!=types2.end()) { extra = gen_var();
            thecode[r] += "\t" + extra + " := cast_to_float "+ codes[b] +"\n";
            thecode[r] += "\t" + v + ":= " + extra + " "+op+"float "+ codes[a]+"\n";
            exptypes[r] = "float";
        }
        else { extra = gen_var();
            thecode[r] += "\t" + v + ":= " + codes[a] + " "+op+"float "+ codes[b]+"\n";
            exptypes[r] = "float";
        }
    }
    codes[r] = v;
}

void mergep(nlist* &n1, nlist* n2){

    if(n2==NULL)
    return ;
    if(n1==NULL)
    {
        n1 = n2;
        return ;
    }

    nlist* one = n1;
    nlist* two = n2;
    nlist* one_tail = one;

    while(one_tail->next != NULL)one_tail = one_tail->next;

    while(two!=NULL)
    {
        nlist* temp = one;
        bool isthere = false;
        while(temp!=NULL)
        {
            if(!strcmp(temp->info.name,two->info.name))isthere = true;
            temp = temp->next;
        }
        if(!isthere)
        {
            one_tail->next = create_nlist(two->info.name, two->info.datatype, two->info.lineno, two->info.type, two->info.dimension, two->info.args, two->info.mod);
            one_tail->next->prev = one_tail;
            one_tail = one_tail->next;
        }

        two = two->next;
    }

    return ;


}

string myclass(nlist *temp){
    string cl;
    while(temp){
            if(!strcmp(temp->info.datatype,"class")) {cl = temp->info.name; break;}
                temp = temp->prev;
        } 
        return cl;
}

void methodinvoc(int a,int r,int ind, string id){
    if(ind==1){
    string cl ;
    nlist *q = find_in_list(global_tail, strdup(exptypes[a].c_str()));
    if(!q){
        q = find_in_list(global_tail, strdup(identifier[a].c_str())); nlist *temp = q;
        cl = myclass(temp);
        exptypes[r] = q->info.datatype;
        thecode[r] += "\tparam this\n";
        if(exptypes[r] != "void") {codes[r] = gen_var();
            thecode[r] += "\t" + codes[r] + ":= call " + cl+ "."+ identifier[a] + "\n";}
        else {thecode[r] += "\tcall " + cl+ "."+ identifier[a] + "\n";}
    }
    else{
        nlist *temp = find_in_list(global_tail, nt[a]->val);
        exptypes[r] = temp->info.datatype;
        thecode[r] += "\tparam "+ codes[a] +"\n";
        if(exptypes[r] != "void") {codes[r] = gen_var();
            thecode[r] += "\t" + codes[r] + ":= call "; thecode[r]= thecode[r] + q->info.datatype + "." + identifier[a] + "\n";}
        else {
            thecode[r] += "\tcall "; thecode[r]= thecode[r] + q->info.datatype + "." + identifier[a] + "\n";
        }
    }
    }
    else {
        string cl = exptypes[a] ;
        if(ind==2) cl= parents[myclass(global_tail)] ;
        thecode[r] += "\tparam "+ codes[a] +"\n";
        if(exptypes[r] != "void") {codes[r] = gen_var();
            thecode[r] += "\t" + codes[r] + ":= call "; thecode[r]= thecode[r] + cl+ "." + id + "\n";}
        else {
            thecode[r] += "\tcall "; thecode[r]= thecode[r] + cl + "." + id + "\n";
        }
    
    }
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
%type<num> MARKBEG
%%

START                   : CompilationUnit              {if(each_symboltable[$1]!=NULL){pop_global(each_symboltable[$1]);
                                                        symboltables.push_back(each_symboltable[$1]);
                                                        each_symboltable[$1] = NULL;
                                                        $$ = $1;}
                                                        fout << "\tEndProgram";}          
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
                                                        codes[$$]= $1;
                                                        if(!classdec.empty() && find(classdec.begin(),classdec.end(),$1)!= classdec.end()) {
                                                            codes[$$] = "*"+codes[$$];
                                                        }
                                                        }
                        ;
MultipleName            : Name DOT IDENTIFIER           { exptypes[$$] = nt[$1]->val;
                                                        strcat(nt[$1]->val,$2);
                                                        strcat(nt[$1]->val,$3);
                                                        identifier[$$] = $3; 
                                                        nlist *q = find_in_list(global_tail, strdup(exptypes[$1].c_str()));
                                                        string cl; if(q) cl = q->info.datatype;
                                                        q = find_in_list(global_tail, nt[$1]->val);
                                                        if(q && q->info.type != 3) {
                                                        string v = gen_var();
                                                        thecode[$$] = thecode[$1] ;//cout << thecode[$1];
                                                        thecode[$$] += "\t" + v + " := " + codes[$1] + " + offset(" + $3 + ","+ cl+ ")\n";
                                                        codes[$$] = "*"+v; 
                                                        $$ = $1;
                                                        }
                                                        } 
                        ;
Modifiers               : STATIC Modifier           {$$ = $2;}
                        | Modifier STATIC           {$$ = $1;}
                        | Modifier                  {$$ = $1;}
                        | STATIC                    {$$ = true;}
                        ;
Modifier                : PUBLIC                    {$$ = true;}
                        | PRIVATE                   {$$ = false;}
                        ;
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
                                                                                list* temp = nt[$2];
                                                                                while(temp){
                                                                                    if(!strcmp(temp->val,"")) {temp = temp->next; continue;}
                                                                                    fout << codes[$1] << "." << temp->val;
                                                                                    temp = temp->next;
                                                                                }
                                                                                classdec.clear();
                                                                            } 
                        | ClassHeader Super ClassBody                       {$$ = $1;
                                                                            pop_pglobal(each_symboltable[$2]);
                                                                            pop_global(each_symboltable[$3]);
                                                                            if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) {
                                                                                nlist* c1 = clone(classtable[nt[$2]->val], false);
                                                                                nlist* c2 = clone(each_symboltable[$3], false);
                                                                                mergep(c2,c1);
                                                                                classtable[each_symboltable[$1]->info.name] = c2;
                                                                            }
                                                                            else yyerror("Class already exists.");
                                                                            mergep(each_symboltable[$3],each_symboltable[$2]);
                                                                            symboltables.push_back(each_symboltable[$3]);
                                                                            parents[each_symboltable[$1]->info.name] = nt[$2]->val;
                                                                            each_symboltable[$2] = NULL;
                                                                            each_symboltable[$3] = NULL;
                                                                            list* temp = nt[$3];
                                                                                while(temp){
                                                                                    fout << codes[$1] << "." << temp->val;
                                                                                    temp = temp->next;
                                                                                }
                                                                                classdec.clear();
                                                                            }
                        ;
ClassHeader             : CLASS IDENTIFIER                              {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($2, 0),create_list($1, 0), yylineno, 2, 0, NULL, true);
                                                                        push_global(each_symboltable[$$]);
                                                                        codes[$$] = $2;}
                        | Modifiers CLASS IDENTIFIER                    {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($3, 0),create_list($2, 0), yylineno, 2, 0, NULL, $1);
                                                                        push_global(each_symboltable[$$]);
                                                                        codes[$$] = $3;}
                        ;
Super                   : EXTENDS ClassType                             {$$ = node;
                                                                        node++;
                                                                        nt[$$] = nt[$2];
                                                                        if(classtable.find(nt[$2]->val)!=classtable.end()) {
                                                                            nlist* c3 = clone(classtable[nt[$2]->val], true);
                                                                            each_symboltable[$$] = c3;
                                                                            push_pglobal(each_symboltable[$$]);
                                                                        }
                                                                        else yyerror("Class not found");}             
                        ;
ClassBody               : OCB CCB                   {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | OCB ClassBodyDeclarations CCB     {$$ = $2;}             
                        ;
ClassBodyDeclarations   : ClassBodyDeclaration      {$$ = $1;
                                                     nt[$$] = create_list(strdup(thecode[$$].c_str()),0 );
                                                    }
                        | ClassBodyDeclarations ClassBodyDeclaration    {$$ = $1;
                                                                            nt[$2] = create_list(strdup(thecode[$2].c_str()),0 );
                                                                            merge(nt[$$],nt[$2]);
                                                                        }
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
                                                                    push_global(each_symboltable[$$]);
                                                                    list* x = nt[$2];
                                                                    while(x){
                                                                        classdec.push_back(x->val);  x = x->next; 
                                                                    }}
                        | Modifiers Type VariableDeclarators SEMICOLON  {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$2], yylineno, 1, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);  
                                                                    list* x = nt[$3];
                                                                    while(x){
                                                                        classdec.push_back(x->val); x = x->next; 
                                                                    }}
                        ;
VariableDeclarators     : VariableDeclarator                            {$$ = $1; thecode[$$] = thecode[$1];}
                        | VariableDeclarators COMMA VariableDeclarator  {merge(nt[$1],nt[$3]);
                                                                        $$ = $1;
                                                                        thecode[$$] = thecode[$1]+ thecode[$3];
                                                                        }
                        ;
VariableDeclarator      : VariableDeclaratorId                          {$$ = $1;}
                        | VariableDeclaratorId EQ VariableInitializer   {$$ = $1;
                                                                          if(nt[$1]->dim == 0) {thecode[$$] = thecode[$3]+"\t"+codes[$1]+" := "+codes[$3]+"\n";}
                                                                        }
                        ;
VariableDeclaratorId    : IDENTIFIER                                    {$$ = node;
                                                                        node++;
                                                                        nt[$$] = create_list($1, 0);
                                                                        codes[$$] = $1;}
                        | VariableDeclaratorId OSB CSB                  {nt[$1]->dim++;
                                                                        $$ = $1;}
                        ;
VariableInitializer     : Expression                                    {$$ = $1;}
                        | ArrayInitializer                              {$$ = $1;}
                        ;
MethodDeclaration       : MethodHeader MethodBody                   {$$ = $1;
                                                                        string sout ;
                                                                        sout = codes[$1]+":\n";
                                                                        nlist *temp = global_tail; string cl;
                                                                        cl = myclass(temp);
                                                                        sout += thecode[$1] ;
                                                                        sout += "\tthis := popparam\n" ;
                                                                            for(int i=0; i< classdec.size(); i++){
                                                                                nlist* q= find_in_list(global_tail,strdup(classdec[i].c_str()));
                                                                                if(q && q->info.type != 3) {
                                                                                    sout = sout+ "\t"+classdec[i] + " := "+ " this + offset(" + classdec[i] +","+ cl +")\n"; 
                                                                                } 
                                                                            }
                                                                            sout+= thecode[$2];
                                                                        thecode[$$] = sout + "\tEndFunction\n";
                                                                    }
                        ;
MethodHeader            : Type MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];
                                                                    if(each_symboltable[$2]) $$ = $2;
                                                                    //search in global_tail and pglobal first if not yet declared
                                                                    codes[$$] = codes[$2]; thecode[$$] = thecode[$2]; }          
                        | Modifiers Type MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$2], yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$3];
                                                                    if(each_symboltable[$3]!=NULL) $$ = $3;
                                                                    codes[$$] = codes[$3]; thecode[$$] = thecode[$3];}
                        | VOID MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];
                                                                    if(each_symboltable[$2]) $$ = $2;
                                                                    codes[$$] = codes[$2]; thecode[$$]= thecode[$2];}
                        | Modifiers VOID MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], create_list($2, 0), yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$3];
                                                                    if(each_symboltable[$3]!=NULL) $$ = $3;
                                                                    codes[$$] = codes[$3]; thecode[$$] = thecode[$3];}
                        ;
MethodDeclarator        : SingleName ONB CNB                            {$$ = $1; codes[$$] = codes[$1]; }
                        | SingleName ONB FormalParameterList CNB        {$$ = $3; 
                                                                        list* k = nt[$3];
                                                                        nt[$$] = nt[$1];
                                                                        args[$$] = k;
                                                                        codes[$$] = codes[$1];
                                                                        thecode[$$] = thecode[$3]; 
                                                                        }
                        ;
FormalParameterList     : FormalParameter                               {$$ = $1; thecode[$$] = "\t"+ codes[$1] + " := popparam\n";}
                        | FormalParameterList COMMA FormalParameter     {merge(nt[$1],nt[$3]);
                                                                        thecode[$$] = thecode[$1] + "\t"+ codes[$3] + " := popparam\n";
                                                                        $$ = $1;
                                                                        }
                        ;
FormalParameter         : Type VariableDeclaratorId                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    nt[$$] = nt[$1];
                                                                    codes[$$] = codes[$2]; 
                                                                    }            
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
                                                                    // each_symboltable[$$] = create_st(nt[$1], create_list("Constructor", 0), yylineno, 3, 0, NULL, true);
                                                                    // push_global(each_symboltable[$$]);
                                                                    // each_symboltable[$$]->info.args = args[$1];
                                                                    string sout;
                                                                    sout = codes[$1]+":\n";
                                                                        nlist *temp = global_tail; string cl;
                                                                        cl = myclass(temp);
                                                                        sout += thecode[$1] ;
                                                                        sout += "\tthis := popparam\n" ;
                                                                            for(int i=0; i< classdec.size(); i++){
                                                                                nlist* q= find_in_list(global_tail,strdup(classdec[i].c_str()));
                                                                                if(q && q->info.type != 3) {
                                                                                    sout = sout+ "\t"+classdec[i] + " := "+ " this + offset(" + classdec[i] +","+ cl +")\n"; 
                                                                                } 
                                                                            } 
                                                                            sout+= thecode[$2];
                                                                        thecode[$$] = sout + "\tEndFunction\n";
                                                                    }
                        | Modifiers ConstructorDeclarator ConstructorBody   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list("Constructor", 0), yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];
                                                                    string sout;
                                                                    sout = codes[$2]+":\n";
                                                                        nlist *temp = global_tail; string cl;
                                                                        cl = myclass(temp);
                                                                        sout += thecode[$2] ;
                                                                        sout += "\tthis := popparam\n" ;
                                                                            for(int i=0; i< classdec.size(); i++){
                                                                                nlist* q= find_in_list(global_tail,strdup(classdec[i].c_str()));
                                                                                if(q && q->info.type != 3) {
                                                                                    sout = sout+ "\t"+classdec[i] + " := "+ " this + offset(" + classdec[i] +","+ cl +")\n"; 
                                                                                } 
                                                                            }
                                                                            sout+= thecode[$3];
                                                                        thecode[$$] = sout + "\tEndFunction\n";
                                                                    }
                        ;
ConstructorDeclarator   : SingleName ONB CNB                        {$$ = $1;}   
                        | SingleName ONB FormalParameterList CNB    {$$ = $1;
                                                                    args[$$] = nt[$3];
                                                                        codes[$$] = codes[$1];
                                                                        thecode[$$] = thecode[$3]; 
                                                                    } 
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
                                                                                } thecode[$$]= thecode[$2];
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
                                                                                thecode[$$] = thecode[$2];
                                                                            }
                        ;
BlockStatements         : BlockStatement                                    {$$ = $1; }
                        | BlockStatements BlockStatement                    {if(each_symboltable[$1]!=NULL) $$ = $1;
                                                                            else $$ = $2;
                                                                            string sout;
                                                                            sout = thecode[$1] + thecode[$2];
                                                                            thecode[$$] = sout; // cout << thecode[$$] <<endl;
                                                                            }
                        ;
BlockStatement          : LocalVariableDeclarationStatement                 {$$ = $1;}
                        | Statement                                         {$$ = $1;}               
                        ;
LocalVariableDeclarationStatement   : LocalVariableDeclaration SEMICOLON    {$$ = $1; }
                                    ;
LocalVariableDeclaration    : Type VariableDeclarators              {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);  
                                                                    thecode[$$] = thecode[$2];
                                                                    }   
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
                                                                                // cout << thecode[$5];  cout << thecode[$3];
                                                                                if(exptypes[$3]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                sout = thecode[$3];
                                                                                string cont = gen_label();
                                                                                sout += "\tifFalse " + codes[$3] + " goto "+ cont +"\n";
                                                                                sout += thecode[$5];
                                                                                sout += cont +":\n";
                                                                                thecode[$$] = sout ;
                                                                            }
                        ;
IfThenElseStatement     : IF ONB Expression CNB StatementNoShortIf ELSE Statement   {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                                if(exptypes[$3]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                sout = thecode[$3];
                                                                                string t= gen_label(), f= gen_label();
                                                                                sout += "\tif "+ codes[$3] + " goto " + t +"\n";
                                                                                sout += thecode[$7] + "\tgoto "+f +"\n";
                                                                                sout += t +":\n"+ thecode[$5];
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout ;
                                                                            }
                        ;
IfThenElseStatementNoShortIf    : IF ONB Expression CNB StatementNoShortIf ELSE StatementNoShortIf  {if(each_symboltable[$5]!=NULL){
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;
                                                                                }
                                                                                if(exptypes[$3]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                sout = thecode[$3];
                                                                                string t= gen_label(), f= gen_label();
                                                                                sout += "\tif "+ codes[$3] + " goto " + t +"\n";
                                                                                sout += thecode[$7] + "\n\tgoto "+f +"\n";
                                                                                sout += t +":\n"+ thecode[$5];
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
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
WhileStatement          : WHILE ONB Expression CNB MARKBEG Statement              {if(each_symboltable[$6]!=NULL){
                                                                                pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;
                                                                                }
                                                                                if(exptypes[$3]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                sout = thecode[$3];
                                                                                string t= currcontext.back().Entry, f= currcontext.back().Exit;
                                                                                sout += t + ":\n\tifFalse "+ codes[$3] + " goto " + f +"\n";
                                                                                sout += thecode[$6] + thecode[$3] + "\tgoto " + t +"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                                currcontext.pop_back();
                                                                            }   
                        ;
WhileStatementNoShortIf : WHILE ONB Expression CNB MARKBEG StatementNoShortIf       {if(each_symboltable[$6]!=NULL){
                                                                                pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;
                                                                                }
                                                                                if(exptypes[$3]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                sout = thecode[$3];
                                                                                string t= currcontext.back().Entry, f= currcontext.back().Exit;
                                                                                sout += t + ":\n\tifFalse "+ codes[$3] + " goto " + f +"\n";
                                                                                sout += thecode[$6] + thecode[$3] + "\tgoto " + t +"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                                currcontext.pop_back();
                                                                            }
                        ;
DoStatement             : DO MARKBEG Statement WHILE ONB Expression CNB SEMICOLON   {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                if(exptypes[$6]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t= currcontext.back().Entry, f= currcontext.back().Exit;
                                                                                sout = t + ":\n";
                                                                                sout += thecode[$3] + thecode[$6];
                                                                                sout += "\tif "+ codes[$6] +" goto "+ t+"\n";
                                                                                sout +=  f +":\n";
                                                                                thecode[$$] = sout;
                                                                                currcontext.pop_back();
                                                                            }
                        ;
ForStatement            : FOR ONB SEMICOLON SEMICOLON CNB Statement         {if(each_symboltable[$6]!=NULL){
                                                                                pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;
                                                                                }
                                                                                string sout;
                                                                                string t = currcontext.back().Entry, f = currcontext.back().Exit;
                                                                                sout = t+":\n" + thecode[$6] +"\tgoto "+ t+"\n";
                                                                                sout += f + ":\n";
                                                                                thecode[$$] = sout;
                                                                            }      
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB Statement {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout= thecode[$3];
                                                                                sout += t+":\n" + thecode[$7] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB Statement  {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                                if(exptypes[$4]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout= thecode[$4];
                                                                                sout += t+":\n\tifFalse "+ codes[$4] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$7] + thecode[$4] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                                }
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB Statement  {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                if(exptypes[$5]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout = thecode[$3];
                                                                                sout+= thecode[$5];
                                                                                sout += t+":\n\tifFalse "+ codes[$5] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$8] + thecode[$5] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB Statement   {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout = t+":\n"; 
                                                                                sout+= thecode[$7] + thecode[$5] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                                }
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB Statement   {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout = thecode[$3];
                                                                                sout += t+":\n"; 
                                                                                sout+= thecode[$8] + thecode[$6] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {if(each_symboltable[$8]!=NULL){
                                                                                pop_global(each_symboltable[$8]);
                                                                                symboltables.push_back(each_symboltable[$8]);
                                                                                each_symboltable[$8] = NULL;
                                                                                $$ = $8;
                                                                                }
                                                                                if(exptypes[$4]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout= thecode[$4];
                                                                                sout += t+":\n\tifFalse "+ codes[$4] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$8] + thecode[$6]+ thecode[$4] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                                }   
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                if(exptypes[$5]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout= thecode[$3]+ thecode[$5];
                                                                                sout += t+":\n\tifFalse "+ codes[$5] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$9] + thecode[$7]+ thecode[$5] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        ;
ForStatementNoShortIf   : FOR ONB SEMICOLON SEMICOLON CNB StatementNoShortIf    {if(each_symboltable[$6]!=NULL){
                                                                                pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout = t+":\n" + thecode[$6] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB StatementNoShortIf    {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout= thecode[$3];
                                                                                sout += t+":\n" + thecode[$7] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                                if(exptypes[$4]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout= thecode[$4];
                                                                                sout += t+":\n\tifFalse "+ codes[$4] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$7] + thecode[$4] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                if(exptypes[$5]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout = thecode[$3];
                                                                                sout+= thecode[$5];
                                                                                sout += t+":\n\tifFalse "+ codes[$5] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$8] + thecode[$5] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf  {if(each_symboltable[$7]!=NULL){
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout = t+":\n"; 
                                                                                sout+= thecode[$7] + thecode[$5] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf  {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                string sout;
                                                                                string t = gen_label();
                                                                                sout = thecode[$3];
                                                                                sout += t+":\n"; 
                                                                                sout+= thecode[$8] + thecode[$6] +"\tgoto "+ t+"\n";
                                                                                thecode[$$] = sout;
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {if(each_symboltable[$8]!=NULL){
                                                                                pop_global(each_symboltable[$8]);
                                                                                symboltables.push_back(each_symboltable[$8]);
                                                                                each_symboltable[$8] = NULL;
                                                                                $$ = $8;
                                                                                }
                                                                                if(exptypes[$4]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout= thecode[$4];
                                                                                sout += t+":\n\tifFalse "+ codes[$4] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$8] + thecode[$6]+ thecode[$4] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                                }  
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                                if(exptypes[$5]!= "boolean") yyerror("condition does not evaluate to boolean");
                                                                                string sout;
                                                                                string t = gen_label(), f= gen_label();
                                                                                sout= thecode[$3]+ thecode[$5];
                                                                                sout += t+":\n\tifFalse "+ codes[$5] + " goto "+ f+ "\n"; 
                                                                                sout+= thecode[$9] + thecode[$7]+ thecode[$5] +"\tgoto "+ t+"\n";
                                                                                sout += f +":\n";
                                                                                thecode[$$] = sout;
                                                                                }  
                        ;
ForInit                 : StatementExpressionList           {$$ = $1;}
                        | LocalVariableDeclaration          {$$ = $1;}
                        ;
ForUpdate               : StatementExpressionList           {$$ = $1;}
                        ;
StatementExpressionList : StatementExpression               {$$ = $1;}
                        | StatementExpressionList COMMA StatementExpression         {$$ = $1;   thecode[$$] = thecode[$3];}
                        ;
BreakStatement          : BREAK SEMICOLON                           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(currcontext.empty()) yyerror("No outer loop detected for break (not handled 'for')");
                                                                    thecode[$$] = "\tgoto " + currcontext.back().Exit + "\n";
                                                                    }              
                        | BREAK IDENTIFIER  SEMICOLON               {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
ContinueStatement       : CONTINUE SEMICOLON                        {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(currcontext.empty()) yyerror("No outer loop detected for continue (not handled 'for')");
                                                                    thecode[$$] = "\tgoto " + currcontext.back().Entry + "\n";
                                                                    } 
                        | CONTINUE IDENTIFIER SEMICOLON             {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
ReturnStatement         : RETURN SEMICOLON                          {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    thecode[$$] = "\treturn\n";} 
                        | RETURN Expression SEMICOLON               {$$ = $2;
                                                                        string sout;
                                                                        sout = thecode[$2];
                                                                        sout += "\treturn "+ codes[$2] + "\n";
                                                                        thecode[$$] = sout;
                                                                    } 
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
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$] = $1; nlist *t= global_tail; exptypes[$$] = myclass(t);
                                                                    } 
                        | ONB Expression CNB                        {$$ = $2;}
                        | ClassInstanceCreationExpression           {$$ = $1;}
                        | FieldAccess                               {$$ = $1;}
                        | MethodInvocation                          {$$ = $1;}
                        | ArrayAccess                               {$$ = $1;}
                        ;
ClassInstanceCreationExpression : NEW ClassType ONB CNB             {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v1 = gen_var(), v2 = gen_var();
                                                                    thecode[$$] = "\t"+v1 + " := " + "sizeof("+ codes[$2] +")\n"; 
                                                                    thecode[$$] = thecode[$$]+ "\t"+"param " + v1 + "\n";
                                                                    thecode[$$] += "\tcall allocmem\n\t" + v2 + " := popparam\n";
                                                                    thecode[$$] += "\tparam "+v2+"\n"+"\tcall "+codes[$2]+"."+codes[$2]+"\n";
                                                                    codes[$$] = v2; exptypes[$$] = codes[$2];
                                                                    }  
                                | NEW ClassType ONB ArgumentList CNB    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v1 = gen_var(), v2 = gen_var();
                                                                    thecode[$$] = "\t"+v1 + " := " + "sizeof("+ codes[$2] +")\n"; 
                                                                    thecode[$$] = thecode[$$]+ "\t"+"param " + v1 + "\n";
                                                                    thecode[$$] += "\tcall allocmem\n\t" + v2 + " := popparam\n";
                                                                    thecode[$$] += "\tparam "+v2+"\n" + thecode[$4];
                                                                    thecode[$$] += "\tcall "+codes[$2]+"."+codes[$2]+"\n";
                                                                    codes[$$] = v2; exptypes[$$] = codes[$2];
                                                                    } 
                                ;
ArgumentList            : Expression                                {$$= node; node++;
                                                                     thecode[$$] = thecode[$1];
                                                                     thecode[$$] += "\tparam " + codes[$1] + "\n";
                                                                    }
                        | ArgumentList COMMA Expression             {
                                                                     $$= node; node++;
                                                                     thecode[$$] = thecode[$1] + thecode[$3];
                                                                     thecode[$$] += "\tparam " + codes[$3] + "\n";
                                                                    }
                        ;
ArrayCreationExpression : NEW PrimitiveType DimExprs                {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v1 = gen_var(), v2 = gen_var();
                                                                    thecode[$$] = thecode[$3] ;
                                                                    thecode[$$] += "\t"+v1 + " := " + "sizeof("+ codes[$2] +") *int "+ codes[$3] +"\n"; 
                                                                    thecode[$$] = thecode[$$]+ "\t"+"param " + v1 + "\n";
                                                                    thecode[$$] += "\tcall allocmem\n\t" + v2 + " := popparam\n";
                                                                    codes[$$] = v2; exptypes[$$] = codes[$2];
                                                                    } 
                        | NEW PrimitiveType DimExprs Dims           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v1 = gen_var(), v2 = gen_var();
                                                                    thecode[$$] = thecode[$3] ;
                                                                    thecode[$$] += "\t"+v1 + " := " + "sizeof("+ codes[$2] +") *int "+ codes[$3] +"\n"; 
                                                                    thecode[$$] = thecode[$$]+ "\t"+"param " + v1 + "\n";
                                                                    thecode[$$] += "\tcall allocmem\n\t" + v2 + " := popparam\n";
                                                                    codes[$$] = v2; exptypes[$$] = codes[$2];} 
                        | NEW ClassOrInterfaceType DimExprs         {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v1 = gen_var(), v2 = gen_var();
                                                                    thecode[$$] = thecode[$3] ;
                                                                    thecode[$$] += "\t"+v1 + " := " + "sizeof("+ codes[$2] +") *int "+ codes[$3] +"\n"; 
                                                                    thecode[$$] = thecode[$$]+ "\t"+"param " + v1 + "\n";
                                                                    thecode[$$] += "\tcall allocmem\n\t" + v2 + " := popparam\n";
                                                                    codes[$$] = v2; exptypes[$$] = codes[$2];} 
                        | NEW ClassOrInterfaceType DimExprs Dims    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v1 = gen_var(), v2 = gen_var();
                                                                    thecode[$$] = thecode[$3] ;
                                                                    thecode[$$] += "\t"+v1 + " := " + "sizeof("+ codes[$2] +") *int "+ codes[$3] +"\n"; 
                                                                    thecode[$$] = thecode[$$]+ "\t"+"param " + v1 + "\n";
                                                                    thecode[$$] += "\tcall allocmem\n\t" + v2 + " := popparam\n";
                                                                    codes[$$] = v2; exptypes[$$] = codes[$2];} 
                        ;
DimExprs                : DimExpr               {$$ = $1;}
                        | DimExprs DimExpr      { $$ = node; node++;
                                                    codes[$$] = gen_var();
                                                    thecode[$$] = thecode[$1] + thecode[$2];
                                                    thecode[$$] += "\t" + codes[$$] + " := " +codes[$1]+ " *int " + codes[$2] + "\n";
                                                }
                        ;
DimExpr                 : OSB Expression CSB    {$$ = $2;}
                        ;
Dims                    : OSB CSB
                        | Dims OSB CSB
                        ;   
FieldAccess             : Primary DOT IDENTIFIER                    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v= gen_var();
                                                                    thecode[$$] = thecode[$1];
                                                                    thecode[$$] += "\t" + v + " := "+codes[$1]+" + offset("+$3+","+ exptypes[$1]+")\n";
                                                                    codes[$$]= v;
                                                                    } 
                        | SUPER DOT IDENTIFIER                      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;   
MethodInvocation        : Name ONB CNB                              {$$ = node;
                                                                    node++; 
                                                                    each_symboltable[$$] = NULL; 
                                                                    methodinvoc($1,$$,1,"");
                                                                    } 
                        | Name ONB ArgumentList CNB                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    thecode[$$] = thecode[$3];
                                                                    methodinvoc($1,$$,1,"");
                                                                    } 
                        | Primary DOT IDENTIFIER ONB CNB            {$$ = node;
                                                                    node++; 
                                                                    each_symboltable[$$] = NULL;
                                                                    thecode[$$] = thecode[$1];
                                                                    methodinvoc($1,$$,0,$3);
                                                                    } 
                        | Primary DOT IDENTIFIER ONB ArgumentList CNB   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    thecode[$$] = thecode[$1] + thecode[$5];
                                                                    methodinvoc($1,$$,0,$3);
                                                                    } 
                        | SUPER DOT IDENTIFIER ONB CNB              {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    // methodinvoc($1,$$,2,$3);
                                                                    } 
                        | SUPER DOT IDENTIFIER ONB ArgumentList CNB {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    // thecode[$$] = thecode[$1] + thecode[$5];
                                                                    // methodinvoc($1,$$,2,$3);
                                                                    } 
                        ;
ArrayAccess             : Name OSB Expression CSB                   {
                                                                        $$=node; node++;
                                                                        nlist* q = find_in_list(global_tail,nt[$1]->val);
                                                                        if(!q) q= find_in_list(pglobal, nt[$1]->val);
                                                                        if(!q) yyerror("variable not declared");
                                                                        if(types2.find(exptypes[$3]) == types2.end()) yyerror("index is not of type int");
                                                                        string v = gen_var();
                                                                        thecode[$$] = thecode[$1]+thecode[$3] ;
                                                                        thecode[$$] += "\t" + v + " := "+ nt[$1]->val +" + "+codes[$3]+"\n";
                                                                        codes[$$] = "*"+v; 
                                                                        exptypes[$$] = q->info.datatype;
                                                                    }
                        | PrimaryNoNewArray OSB Expression CSB      {
                                                                        $$=node; node++;
                                                                        if(types2.find(exptypes[$3]) == types2.end()) yyerror("index is not of type int");
                                                                        string v = gen_var();
                                                                        thecode[$$] = thecode[$1] + thecode[$3] ;
                                                                        thecode[$$] += "\t" + v + " := "+ codes[$1] +"+ "+codes[$3]+"\n";
                                                                        codes[$$] = "*"+v; 
                                                                        exptypes[$$] = exptypes[$1];
                                                                    }
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
                                                                    string v= gen_var();
                                                                    thecode[$$] = thecode[$1] ;
                                                                    thecode[$$]+= "\t"+v+" := "+codes[$1]+"\n";
                                                                    if(types2.find(exptypes[$1]) != types2.end()){
                                                                    thecode[$$]+= "\t"+codes[$1]+":= "+codes[$1]+" +int 1"+"\n";
                                                                    }
                                                                    else if(types3.find(exptypes[$1]) != types3.end()){
                                                                    thecode[$$]+= "\t"+codes[$1]+":= "+codes[$1]+" +float 1"+"\n";
                                                                    }
                                                                    else{
                                                                        yyerror("incompatible operand types for ++");
                                                                    }
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$1];
                                                                    } 
                        ;   
PostDecrementExpression : PostfixExpression DEC                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    string v= gen_var();
                                                                    thecode[$$] = thecode[$1] ;
                                                                    thecode[$$]+= "\t"+v+" := "+codes[$1]+"\n";
                                                                    if(types2.find(exptypes[$1]) != types2.end()){
                                                                    thecode[$$]+= "\t"+codes[$1]+":= "+codes[$1]+" -int 1"+"\n";
                                                                    }
                                                                    else if(types3.find(exptypes[$1]) != types3.end()){
                                                                    thecode[$$]+= "\t"+codes[$1]+":= "+codes[$1]+" -float 1"+"\n";
                                                                    }
                                                                    else{
                                                                        yyerror("incompatible operand types for --");
                                                                    }
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$1];
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
                                                                        thecode[$$] = thecode[$2] ;
                                                                        thecode[$$] += "\t"+v+":= "+" -"+codes[$2]+"\n";
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
                                                                    thecode[$$] = thecode[$2] ;
                                                                    if(types2.find(exptypes[$2]) != types2.end()){
                                                                        thecode[$$] += "\t"+codes[$2]+":= "+codes[$2]+" +int 1"+"\n";
                                                                    } 
                                                                    else if(types3.find(exptypes[$2]) != types3.end()){
                                                                        thecode[$$] += "\t"+codes[$2]+":= "+codes[$2]+" +float 1"+"\n";
                                                                    } 
                                                                    else yyerror("incompatible operand type for ++");
                                                                        codes[$$] = codes[$2];
                                                                        exptypes[$$] = exptypes[$2];
                                                                    } 
                        ;
PreDecrementExpression  : DEC UnaryExpression                       {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    thecode[$$] = thecode[$2] ;
                                                                    if(types2.find(exptypes[$2]) != types2.end()){
                                                                        thecode[$$] += "\t"+codes[$2]+":= "+codes[$2]+" -int 1"+"\n";
                                                                    } 
                                                                    else if(types3.find(exptypes[$2]) != types3.end()){
                                                                        thecode[$$] += "\t"+codes[$2]+":= "+codes[$2]+" -float 1"+"\n";
                                                                    } 
                                                                    else yyerror("incompatible operand type for --");
                                                                        codes[$$] = codes[$2];
                                                                        exptypes[$$] = exptypes[$2];
                                                                    } 
                        ;
UnaryExpressionNotPlusMinus : PostfixExpression         {$$ = $1;}
                            | NEG UnaryExpression       {   $$ = node; node++;
                                                            if(types2.find(exptypes[$2]) == types2.end()) yyerror("incompatible operand type");
                                                                        string v= gen_var();
                                                                        thecode[$$] = thecode[$2] ;
                                                                        thecode[$$] += "\t"+v+":= "+"~ "+codes[$2]+"\n";
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$2];
                                                                        }
                            | NOT UnaryExpression       {   $$ = node; node++;
                                                            if(exptypes[$2]!= "boolean") yyerror("incompatible operand type");
                                                                        string v= gen_var();
                                                                        thecode[$$] = thecode[$2] ;
                                                                        thecode[$$] += "\t"+v+":= "+"! "+codes[$2]+"\n";
                                                                        codes[$$] = v;
                                                                        exptypes[$$] = exptypes[$2];
                                                                        }
                            | CastExpression            {$$ = $1;}
                            ;
CastExpression          : ONB PrimitiveType CNB UnaryExpression         {   $$ = node; node++; //cout+"cout"+exptypes[$2]+" 4"+exptypes[$4];
                                                                        if(types1.find(exptypes[$2]) != types1.end()){
                                                                            if(types1.find(exptypes[$4]) != types1.end()){
                                                                        string v= gen_var();
                                                                        thecode[$$] =  thecode[$4];
                                                                        thecode[$$] += "\t"+v+":= "+"cast_to_"+codes[$2]+" "+codes[$4]+"\n";
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
                                                                    thecode[$$] = thecode[$1] + thecode[$3];
                                                                    thecode[$$] += "\t" + v + ":="  + codes[$1] +" "+$2+" " + codes[$3]+"\n";
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
                                                                    thecode[$$] = thecode[$1] + thecode[$3];
                                                                    thecode[$$] += "\t" + v + ":= " + codes[$1] + " "+ $2 +" " + codes[$3]+"\n";
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        | RelationalExpression INSTANCEOF ReferenceType   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1]) != types1.end() || types1.find(exptypes[$3]) != types1.end()) 
                                                                        yyerror("incompatible operand types for instanceof");
                                                                    string v= gen_var();
                                                                    thecode[$$] = thecode[$1] + thecode[$3];
                                                                    thecode[$$] += "\t" + v + ":=" + codes[$1] + " "+ $2 +" " + codes[$3]+"\n";
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
                                                                    thecode[$$] = thecode[$1] + thecode[$3];
                                                                    string v= gen_var();
                                                                    thecode[$$] += "\t" + v + ":= " + codes[$1] + " = " + codes[$3]+"\n";
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        | EqualityExpression RELNOTEQ RelationalExpression  {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    if(types1.find(exptypes[$1])==types1.end() || types1.find(exptypes[$3])==types1.end()){
                                                                        if(exptypes[$1]== "String" && exptypes[$3]== "String");
                                                                        else yyerror("incompatible operand types for !=");}
                                                                    thecode[$$] = thecode[$1] + thecode[$3];
                                                                    string v= gen_var();
                                                                    thecode[$$] += "\t" + v + ":= " + codes[$1] + " "+ $2 +" " + codes[$3]+"\n";
                                                                    codes[$$] = v;
                                                                    exptypes[$$] = "boolean";
                                                                    } 
                        ;
AndExpression           : EqualityExpression                        {$$ = $1;}
                        | AndExpression AND EqualityExpression      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    exptypes[$$] = "int";   thecode[$$] = thecode[$1] + thecode[$3];
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end()){
                                                                        if(exptypes[$1]== "boolean" && exptypes[$3]== "boolean") exptypes[$$] = "boolean";
                                                                        else yyerror("incompatible operand types for &");}
                                                                    string v= gen_var();
                                                                    thecode[$$] += "\t" + v + ":= " + codes[$1] + " "+ $2 +" " + codes[$3]+"\n";
                                                                    codes[$$] = v;
                                                                    } 
                        ;
ExclusiveOrExpression   : AndExpression                             {$$ = $1;}
                        | ExclusiveOrExpression UP AndExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    exptypes[$$] = "int";   thecode[$$] = thecode[$1] + thecode[$3];
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end()){
                                                                        if(exptypes[$1]== "boolean" && exptypes[$3]== "boolean") exptypes[$$] = "boolean";
                                                                        else yyerror("incompatible operand types for ^");}
                                                                    string v= gen_var();
                                                                    thecode[$$] += "\t" + v + ":= " + codes[$1] + " "+ $2 +" " + codes[$3]+"\n";
                                                                    codes[$$] = v;
                                                                    } 
                        ;
InclusiveOrExpression   : ExclusiveOrExpression                     {$$ =$1;}
                        | InclusiveOrExpression OR ExclusiveOrExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    exptypes[$$] = "int";   thecode[$$] = thecode[$1] + thecode[$3];
                                                                    if(types2.find(exptypes[$1])==types2.end() || types2.find(exptypes[$3])==types2.end()){
                                                                        if(exptypes[$1]== "boolean" && exptypes[$3]== "boolean") exptypes[$$] = "boolean";
                                                                        else yyerror("incompatible operand types for |");}
                                                                    string v= gen_var();
                                                                    thecode[$$] += "\t" + v + ":= " + codes[$1] + " "+ $2 +" " + codes[$3]+"\n";
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
                                                                    string v= gen_var(),t= gen_label(), f= gen_label();
                                                                    thecode[$$] = thecode[$1] ;
                                                                    thecode[$$] = thecode[$$]+ "\t" + "ifFalse "+ codes[$1] +" goto "+t+"\n";
                                                                    thecode[$$] += thecode[$3] ;
                                                                    thecode[$$] = thecode[$$]+ "\t" + "ifFalse "+ codes[$3] +" goto "+t+"\n";
                                                                    thecode[$$] = thecode[$$]+ "\t" + v + ":= true" +"\n";
                                                                    thecode[$$] = thecode[$$]+ "\tgoto "+ f +"\n";
                                                                    thecode[$$] = thecode[$$]+ t+ ":\n\t" + v + ":= false" +"\n";
                                                                    thecode[$$] = thecode[$$]+ f+ ":\n" ;
                                                                    codes[$$] = v; exptypes[$$]= "boolean";
                                                                    } 
                            ;
ConditionalOrExpression : ConditionalAndExpression                                          {$$ = $1;}
                        | ConditionalOrExpression RELOR ConditionalAndExpression            {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL; 
                                                                    if(exptypes[$1]!= "boolean" || exptypes[$3]!= "boolean")
                                                                        yyerror("incompatible operand types for ||");
                                                                    exptypes[$$] = "boolean";
                                                                    string v= gen_var(),t= gen_label(), f= gen_label();
                                                                    thecode[$$] = thecode[$1] ;
                                                                    thecode[$$] = thecode[$$]+"\t" + "if "+ codes[$1] +" goto "+t+"\n";
                                                                    thecode[$$] += thecode[$3] ;
                                                                    thecode[$$] = thecode[$$]+ "\t" + "if "+ codes[$3] +" goto "+t+"\n";
                                                                    thecode[$$] = thecode[$$]+ "\t" + v + ":= false" +"\n";
                                                                    thecode[$$] = thecode[$$]+ "\tgoto "+ f +"\n";
                                                                    thecode[$$] = thecode[$$]+ t+ ":\n\t" + v + ":= true" +"\n";
                                                                    thecode[$$] = thecode[$$]+ f+ ":\n" ;
                                                                    codes[$$] = v;  exptypes[$$]= "boolean";
                                                                    } 
                        ;
ConditionalExpression   : ConditionalOrExpression                                           {$$ = $1;}
                        | ConditionalOrExpression QM Expression COLON ConditionalExpression {   string t = gen_label(), f= gen_label(), v= gen_var();
                                                                                                thecode[$$] = thecode[$1] + thecode[$3] + thecode[$5];
                                                                                                thecode[$$] = thecode[$$]+ "\t"+"if "+codes[$1]+" goto "+t+"\n";
                                                                                                thecode[$$] = thecode[$$]+ "\t"+v+":= "+codes[$5]+"\n";
                                                                                                thecode[$$] = thecode[$$]+ "\t"+"goto "+f+"\n";
                                                                                                thecode[$$] = thecode[$$]+ t+":\n\t"+v+":= "+codes[$3]+"\n";
                                                                                                thecode[$$] = thecode[$$]+ f+":\n";
                                                                                                $$ = node; node++;
                                                                                                codes[$$] = v;
                                                                                                exptypes[$$] = "int";
                                                                                            }
                        ;
AssignmentExpression    : ConditionalExpression         {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$] = codes[$1]; exptypes[$$] = exptypes[$1]; thecode[$$] = thecode[$1];
                                                                    } 
                        | Assignment                    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$] = codes[$1]; exptypes[$$] = exptypes[$1]; thecode[$$] = thecode[$1];
                                                                    } 
                        ;
Assignment              : LeftHandSide Assignment_Operators AssignmentExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    thecode[$$] = thecode[$1] + thecode[$3];
                                                                    if(types2.find(exptypes[$1])!=types2.end() && types2.find(exptypes[$3])!=types2.end()) 
                                                                    {
                                                                         if(codes[$2]== "=") thecode[$$] += "\t" + codes[$1] + " := " + codes[$3]+"\n";
                                                                         else if(codes[$2] != "&=") thecode[$$] += "\t" + codes[$1] + " := " + codes[$1]+" "+codes[$2][0]+"int "+codes[$3]+"\n";
                                                                         else thecode[$$] += "\t" + codes[$1] + " := " + codes[$1]+" "+codes[$2][0]+" "+codes[$3]+"\n";
                                                                    }
                                                                    else if(types3.find(exptypes[$1])!=types3.end() && types3.find(exptypes[$3])!=types3.end()) 
                                                                    {
                                                                        if(codes[$2] == "&=") yyerror("incompatible operand types");
                                                                        else if(codes[$2]== "=") thecode[$$] += "\t" + codes[$1] + " := " + codes[$3]+"\n";
                                                                         else thecode[$$] += "\t" + codes[$1] + " := " + codes[$1]+" "+codes[$2][0]+"float "+codes[$3]+"\n";
                                                                    }
                                                                    else if(exptypes[$1]==exptypes[$3]){ 
                                                                        if(codes[$2] == "&=" && exptypes[$1]=="boolean") thecode[$$] += "\t" + codes[$1] + " := " + codes[$1]+" "+codes[$2][0]+" "+codes[$3]+"\n";
                                                                        else if(codes[$2]== "=") thecode[$$] += "\t" + codes[$1] + " := " + codes[$3]+"\n";
                                                                         else yyerror("incompatible types for assignment");
                                                                    }
                                                                    else if(types3.find(exptypes[$1])!=types3.end() && types2.find(exptypes[$3])!=types2.end()){
                                                                        if(codes[$2]== "=") thecode[$$] += "\t" + codes[$1] + " := cast_to_float " + codes[$3]+"\n";
                                                                        else {
                                                                            if(codes[$2] == "&=") yyerror("incompatible operand types");
                                                                            string v= gen_var();
                                                                            thecode[$$] += "\t" + v + " := cast_to_float " + codes[$3]+"\n";
                                                                            thecode[$$] += "\t" + codes[$1] + " := " + codes[$1]+" "+codes[$2][0]+"float "+v+"\n";
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
LeftHandSide            : Name                                     {$$ = $1; // cout+"variabel="+nt[$1]->val+"\n";
                                                                     nlist *q = find_in_list(global_tail,nt[$1]->val);
                                                                    if(!q) yyerror("variable not declared in this scope");
                                                                    exptypes[$$] = q->info.datatype;
                                                                    }
                        | FieldAccess                               {$$ = $1;}
                        | ArrayAccess                               {$$ = $1;}
                        ;
Expression              : AssignmentExpression                      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$]=codes[$1]; exptypes[$$] = exptypes[$1]; thecode[$$] = thecode[$1];} 
                        ;
ConstantExpression      : Expression                                {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;
                                                                    codes[$$]=codes[$1]; exptypes[$$] = exptypes[$1]; thecode[$$] = thecode[$1];} 
                        ;
MARKBEG                 : %empty                                    {
                                                                        context temp; temp.Entry = gen_label(); temp.Exit = gen_label();
                                                                        currcontext.push_back(temp);
                                                                    }
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
        cout << "The syntax for execution is: program input_filename output_filename" << "\n";
        return 0;
    }

    FILE *infile = fopen(argv[1], "r");
    outfile.open(argv[2], ios::trunc);
    
    if (!infile) {
        cout << "I can't open the file!" << "\n";
        return -1;
    }
    yyin = infile;
    yyparse();
    fclose(infile);

    symboltables.push_back(Global);

    outfile << "Name, " << "DataType, " << "LineNO, " << "Type, " << "ArgumentsOrDimensions" << "\n" << "\n";

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
            outfile << "\n";
            temp = temp->next;
        }
        outfile << "\n"; 
    }
    //fout << "System.out.println:\n\tprint()"
    outfile.close();
    fout.close();
	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nIn Line number:%d\n", s, yylineno); exit(0);}