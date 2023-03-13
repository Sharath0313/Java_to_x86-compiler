%{
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <algorithm> 
#include <cstdio>
#include <map>
#include <cstring>
using namespace std;

void yyerror (char *s);
extern char* yytext;
extern int yylineno;
extern FILE *yyin;
int yylex();
ofstream outfile;
int node = 0;

struct list{
    char* val;
    int dim;
    struct list* next;
    struct list* prev;
} typedef list;

struct symrec{
    char *name,*datatype;
    int lineno,type,dimension;       // 1->localvar 2->class 3->method 4->import 5->package
    list* args;
} typedef symrec;

symrec create_symrec(char* name, char* datatype, int lineno, int type, int dimension, list* args){

    symrec temp;
    temp.name = name;
    temp.datatype = datatype;
    temp.lineno = lineno;
    temp.type = type;
    temp.dimension = dimension;
    temp.args = args;

    return temp;

}

struct nlist{
    symrec info;
    struct nlist* next;
    struct nlist* prev;
} typedef nlist;

nlist* create_nlist(char* name, char* datatype, int lineno, int type, int dimension, list* args){

    nlist* temp = new nlist;
    symrec t = create_symrec(name, datatype, lineno, type, dimension, args);
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

map<int, list*> nt;
map<int, list*> args;
map<int, nlist*> each_symboltable;
map<int, int> parents;
vector<nlist*> symboltables;
map<string, nlist*> classtable;
map<string, nlist*> interfacetable;
nlist* Global = create_nlist("global", "none", -1, -1, -1, NULL);
nlist* global_tail = Global;

void out(nlist* t){
    
    nlist* temp = t;
    while(temp!=NULL){
        cout << temp->info.name << ", " << temp->info.datatype << ", " << temp->info.lineno << ", " << temp->info.type << ", " << temp->info.dimension << endl;
        temp = temp->next;
    }

    return ;

}

nlist* clone(nlist* l){

    nlist* k = NULL;
    nlist* a = l;
    if(a==NULL)return k;

    k = create_nlist(a->info.name, a->info.datatype, a->info.lineno, a->info.type, a->info.dimension, a->info.args);
    nlist* t = k;
    a = a->next;

    while(a!=NULL){
        t->next = create_nlist(a->info.name, a->info.datatype, a->info.lineno, a->info.type, a->info.dimension, a->info.args);
        t->next->prev = t;
        a = a->next;
        t = t->next;
    }
    
    return k;

}

void push_global(nlist* nl){
    
    global_tail->next = nl;
    nl->prev = global_tail;

    while(global_tail->next != NULL)global_tail = global_tail->next;

    return;

}

void pop_global(nlist* nl){

    global_tail = nl->prev;
    global_tail->next = NULL;

    return ;

}

void merge(list* n1, list* n2){

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

nlist* create_st(list* name, list* datatype, int lineno, int type, int dimension, list* args){

    if(datatype == NULL || datatype->next != NULL)
    return NULL;

    if(!strcmp(datatype->val,"int") || !strcmp(datatype->val,"long") || !strcmp(datatype->val,"char") || !strcmp(datatype->val,"float") || !strcmp(datatype->val,"double") || !strcmp(datatype->val,"String") || !strcmp(datatype->val,"class") || !strcmp(datatype->val,"interface") || !strcmp(datatype->val,"void"))
    {
        list* temp = name;
        nlist* k = create_nlist(temp->val, datatype->val, lineno, type, dimension + temp->dim + datatype->dim, args);
        nlist* t = k;
        temp = temp->next;

        while(temp!=NULL)
        {
            t->next = create_nlist(temp->val, datatype->val, lineno, type, dimension + temp->dim + datatype->dim, args);
            t->next->prev = t;
            t = t->next;
            temp = temp->next;
        }

        return k;
    }
    else if(classtable.find(datatype->val)!=classtable.end())
    {
        nlist* k = clone(classtable[datatype->val]);
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
            temp->next = clone(classtable[datatype->val]);
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
        nlist* k = clone(interfacetable[datatype->val]);
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
            temp->next = clone(interfacetable[datatype->val]);
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
    else
    {
        yyerror("Type not found.");
        return NULL;
    } 
}


%}

%union{
    int num;
    char id;
    char* str;
}

%start START 
%token<str> INTEGRALTYPE FLOATINGPOINTTYPE BOOL_LITERAL ASSIGNMENT_OPERATOR SHIFT RELGL INT_LITERAL FLOAT_LITERAL CHAR_LITERAL STRING_LITERAL TEXT_BLOCK IDENTIFIER NULL_LITERAL
%token<str> BOOLEAN EXTENDS SUPER INTERFACE PUBLIC PROTECTED PRIVATE ABSTRACT STRINGTYPE
%token<str> STATIC FINAL DEFAULT CLASS IMPLEMENTS THROWS THIS SYNCHRONIZED 
%token<str> VOID SWITCH CONTINUE FOR NEW IF DO BREAK THROW ELSE CASE INSTANCEOF RETURN TRANSIENT 
%token<str> CATCH TRY FINALLY VOLATILE NATIVE WHILE   
%token<str> INC DEC RELAND RELOR RELEQ RELNOTEQ 
%token<str> PACKAGE IMPORT SEMICOLON DOT STAR OSB CSB OCB CCB ONB CNB COMMA COLON PLUS MINUS NEG NOT DIV MOD AND UP OR QM EQ
%type<num>  START CompilationUnit ImportDeclarations TypeDeclarations PackageDeclaration ImportDeclaration SingleTypeImportDeclaration  
%type<num>  TypeImportOnDemandDeclaration TypeDeclaration  Name SingleName MultipleName Modifiers Modifier Type PrimitiveType ReferenceType ClassHeader
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
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 5, 0, NULL);
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
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 4, 0, NULL);
                                                                    push_global(each_symboltable[$$]);}  
                            ;
TypeImportOnDemandDeclaration   : IMPORT Name DOT STAR SEMICOLON    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 4, 0, NULL);
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
                                                    each_symboltable[$$] = NULL;}
                        | FLOAT_LITERAL             {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | BOOL_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | CHAR_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | STRING_LITERAL            {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | NULL_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | TEXT_BLOCK                {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        ;

Name                    : SingleName                    {$$ = $1;}
                        | MultipleName                  {$$ = $1;}
                        ;   
SingleName              : IDENTIFIER                    {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0);}
                        ;
MultipleName            : Name DOT IDENTIFIER           {strcat(nt[$1]->val,$2);
                                                        strcat(nt[$1]->val,$3);
                                                        $$ = $1;} 
                        ;

Modifiers               : Modifier                      {$$ = $1;}
                        | Modifiers Modifier            {if(each_symboltable[$1]!=NULL) $$ = $1;
                                                        else $$ = $2;}
                        ;   
Modifier                : PUBLIC                    {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | PROTECTED                 {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | PRIVATE                   {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | STATIC                    {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | ABSTRACT                  {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | FINAL                     {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | NATIVE                    {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | SYNCHRONIZED              {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | TRANSIENT                 {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        | VOLATILE                  {$$ = node;
                                                    node ++;
                                                    each_symboltable[$$] = NULL;}
                        ;

Type                    : PrimitiveType                 {$$ = $1;}
                        | ReferenceType                 {$$ = $1;}
                        ;
PrimitiveType           : NumericType                   {$$ = $1;}
                        | BOOLEAN                       {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0);}
                        | STRINGTYPE                    {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0);}
                        ;
NumericType             : INTEGRALTYPE                  {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0);}
                        | FLOATINGPOINTTYPE             {$$ = node;
                                                        node++;
                                                        nt[$$] = create_list($1, 0);}
                        
                        ;
ReferenceType           : ClassOrInterfaceType          {$$ = $1;} 
                        | ArrayType                     {$$ = $1;}
                        ;
ClassOrInterfaceType    : Name                          {$$ = $1;}                
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

ClassDeclaration        : ClassHeader ClassBody                             {$$ = $1;
                                                                            if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) classtable[each_symboltable[$1]->info.name] = each_symboltable[$2];
                                                                                else yyerror("Class already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            } 
                        | ClassHeader Super ClassBody                       {$$ = $1;
                                                                            if(each_symboltable[$2]!=NULL){
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) classtable[each_symboltable[$1]->info.name] = each_symboltable[$2];
                                                                                else yyerror("Class already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            }
                        ;
ClassHeader             : CLASS IDENTIFIER                              {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($2, 0),create_list($1, 0), yylineno, 2, 0, NULL);
                                                                        push_global(each_symboltable[$$]);}
                        | Modifiers CLASS IDENTIFIER                    {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($3, 0),create_list($2, 0), yylineno, 2, 0, NULL);
                                                                        push_global(each_symboltable[$$]);}
                        ;
Super                   : EXTENDS ClassType                             {$$ = node;
                                                                        node++;
                                                                        if(classtable.find(nt[$2]->val)!=classtable.end()) {
                                                                            each_symboltable[$$] = clone(classtable[nt[$2]->val]);
                                                                            push_global(each_symboltable[$$]);
                                                                        }
                                                                        else yyerror("Class not found");}             
                        ;
ClassBody               : OCB CCB                   {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        | OCB ClassBodyDeclarations CCB      {$$ = $2;}               
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
FieldDeclaration        : Type VariableDeclarators SEMICOLON        {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL);
                                                                    push_global(each_symboltable[$$]);}
                        | Modifiers Type VariableDeclarators SEMICOLON  {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$2], yylineno, 1, 0, NULL);
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
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];}          
                        | Modifiers Type MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$1], yylineno, 3, 0, NULL);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$3];}
                        | VOID MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 3, 0, NULL);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$2];}
                        | Modifiers VOID MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], create_list($2, 0), yylineno, 3, 0, NULL);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$3];}
                        ;
MethodDeclarator        : SingleName ONB CNB                            {$$ = $1;}
                        | SingleName ONB FormalParameterList CNB        {$$ = $1;
                                                                        args[$$] = nt[$3];}
                        | MethodDeclarator OSB CSB                      {$$ = $1;}
                        ;
FormalParameterList     : FormalParameter                               {$$ = $1;}
                        | FormalParameterList COMMA FormalParameter     {merge(nt[$1],nt[$3]);
                                                                        $$ = $1;}
                        ;
FormalParameter         : Type VariableDeclaratorId                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL);
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
                                                                    each_symboltable[$$] = create_st(nt[$1], create_list("Constructor", 0), yylineno, 3, 0, NULL);
                                                                    push_global(each_symboltable[$$]);
                                                                    each_symboltable[$$]->info.args = args[$1];}
                        | Modifiers ConstructorDeclarator ConstructorBody   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list("Constructor", 0), yylineno, 3, 0, NULL);
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
                                                                                if(interfacetable.find(each_symboltable[$1]->info.name)==interfacetable.end()) interfacetable[each_symboltable[$1]->info.name] = each_symboltable[$2];
                                                                                else yyerror("Interface already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            }                   
                        ;
InterfaceHeader         : INTERFACE IDENTIFIER                          {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($2, 0),create_list($1, 0), yylineno, 2, 0, NULL);
                                                                        push_global(each_symboltable[$$]);}
                        | Modifiers INTERFACE IDENTIFIER                {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($3, 0),create_list($2, 0), yylineno, 2, 0, NULL);
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
LocalVariableDeclarationStatement   : LocalVariableDeclaration SEMICOLON    {$$ = $1;}
                                    ;
LocalVariableDeclaration    : Type VariableDeclarators              {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL);
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
PostfixExpression       : Primary   
                        | Name
                        | PostIncrementExpression
                        | PostDecrementExpression
                        ;
PostIncrementExpression : PostfixExpression INC                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;   
PostDecrementExpression : PostfixExpression DEC                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
UnaryExpression         : PreIncrementExpression
                        | PreDecrementExpression
                        | PLUS UnaryExpression
                        | MINUS UnaryExpression
                        | UnaryExpressionNotPlusMinus
                        ;
PreIncrementExpression  : INC UnaryExpression                       {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
PreDecrementExpression  : DEC UnaryExpression                       {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
UnaryExpressionNotPlusMinus : PostfixExpression
                            | NEG UnaryExpression
                            | NOT UnaryExpression
                            | CastExpression 
                            ;
CastExpression          : ONB PrimitiveType CNB UnaryExpression
                        | ONB PrimitiveType Dims CNB UnaryExpression
                        | ONB Expression CNB UnaryExpressionNotPlusMinus
                        | ONB Name Dims CNB UnaryExpressionNotPlusMinus
                        ;
MultiplicativeExpression    : UnaryExpression
                            | MultiplicativeExpression STAR UnaryExpression
                            | MultiplicativeExpression DIV UnaryExpression
                            | MultiplicativeExpression MOD UnaryExpression
                            ;
AdditiveExpression      : MultiplicativeExpression
                        | AdditiveExpression PLUS MultiplicativeExpression   
                        | AdditiveExpression MINUS MultiplicativeExpression
                        ;
ShiftExpression         : AdditiveExpression
                        | ShiftExpression SHIFT AdditiveExpression
                        ;
RelationalExpression    : ShiftExpression
                        | RelationalExpression RELGL ShiftExpression
                        | RelationalExpression INSTANCEOF ReferenceType
                        ;
EqualityExpression      : RelationalExpression
                        | EqualityExpression RELEQ RelationalExpression
                        | EqualityExpression RELNOTEQ RelationalExpression
                        ;
AndExpression           : EqualityExpression
                        | AndExpression AND EqualityExpression
                        ;
ExclusiveOrExpression   : AndExpression
                        | ExclusiveOrExpression UP AndExpression
                        ;
InclusiveOrExpression   : ExclusiveOrExpression
                        | InclusiveOrExpression OR ExclusiveOrExpression
                        ;
ConditionalAndExpression    : InclusiveOrExpression
                            | ConditionalAndExpression RELAND InclusiveOrExpression
                            ;
ConditionalOrExpression : ConditionalAndExpression
                        | ConditionalOrExpression RELOR ConditionalAndExpression
                        ;
ConditionalExpression   : ConditionalOrExpression
                        | ConditionalOrExpression QM Expression COLON ConditionalExpression
                        ;
AssignmentExpression    : ConditionalExpression         {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        | Assignment                    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
Assignment              : LeftHandSide Assignment_Operators AssignmentExpression    {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
Assignment_Operators    : ASSIGNMENT_OPERATOR
                        | EQ
                        ;
LeftHandSide            : Name
                        | FieldAccess
                        | ArrayAccess
                        ;
Expression              : AssignmentExpression                      {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;
ConstantExpression      : Expression                                {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
                        ;

%%                    


int main (int argc, char** argv) {

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

    // out(Global);

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

	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nIn Line number:%d\n", s, yylineno); exit(0);} 