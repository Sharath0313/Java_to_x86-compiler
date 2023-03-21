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
    int lineno,type,dimension;       // 1->localvar 2->class 3->method 4->import 5->package 6->Constructor
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

nlist* find_in_list(nlist* tail,char* id);
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
map<int, stringstream> thecode;
map<int, symrec> each_symrec;
nlist* Construct = NULL;

void out(nlist* t){
    
    nlist* temp = t;
    while(temp!=NULL)
    {
        cout << temp->info.name << ", " << temp->info.datatype << ", " << temp->info.lineno << ", " << temp->info.type << ", " << temp->info.dimension << ", ARGS: ";
        list* a = temp->info.args;
        if(a!=NULL)
        {
            cout << a->val << "(" << a->dim << ")";
            a = a->next;
            while(a!=NULL)
            {
                cout << ", " << a->val << "(" << a->dim << ")";
                a = a->next;
            }
        }
        cout << endl;
        temp = temp->next;
    }
    cout << endl; 

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

nlist* new_clone(string k){

    if(classtable.find(k)==classtable.end()) 
    {
        yyerror("Class not found.");
        return NULL;
    }

    nlist* res = clone(classtable[k], false);
    nlist* temp = res;

    while(temp!=NULL)
    {
        string p = "new " + k + "()";
        char* z = const_cast<char*>(p.c_str());
        temp->info.name = strdup(strcat(z,temp->info.name));
        temp = temp->next; 
    }

    return res;

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
        if(!strcmp(t->info.name, id))
        {
            nlist* res = create_nlist(t->info.name, t->info.datatype, t->info.lineno, t->info.type, t->info.dimension, t->info.args, t->info.mod);
            return res;
        }
        t = t->prev;
    }
    return NULL;
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

void create_cons(char* name, char* datatype, int lineno, int type, int dimension, list* args, bool mod){

    nlist* temp = global_tail;
    while(temp!=NULL)
    {
        if(!strcmp(temp->info.name, name))
        break;

        temp = temp->prev;
    }

    if(temp==NULL)
    {
        yyerror("Invalid Constructor");
        return ;
    }

    Construct = create_nlist(name, datatype, lineno, type, dimension, args, mod);

    return;

}

bool cmplist(list* a, list* b){

    if(a==NULL && b==NULL)
    return true;
    else if(b==NULL)
    return false;
    else if(!strcmp(b->val, "all"))
    return true;
    else if(a==NULL)
    return false;
    else
    {
        if(!strcmp(a->val,b->val) && (a->dim == b->dim))
        return cmplist(a->next, b->next);
        else return false;
    }

}

void cmpsym(symrec n1, symrec n2){

    if(strcmp(n1.datatype, n2.datatype) && strcmp(n1.datatype,"all") && strcmp(n2.datatype,"all")) yyerror("Datatype doesn't match");
    if(n1.type != n2.type) yyerror("Datatype doesn't match");
    if(n1.dimension != n2.dimension) yyerror("Dimensions doesn't match");
    if(!cmplist(n1.args, n2.args)) yyerror("Arguments doesn't match");
    
    return ;

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
%type<num>  MethodDeclaration MethodHeader MethodDeclarator FormalParameterList FormalParameter MethodBody StaticInitializer ConstructorHeader
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
                                                    each_symrec[$$] = create_symrec("", "int", yylineno, 1, 0, NULL, true);}
                        | FLOAT_LITERAL             {$$ = node;
                                                    node++;
                                                    each_symrec[$$] = create_symrec("", "float", yylineno, 1, 0, NULL, true);}
                        | BOOL_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symrec[$$] = create_symrec("", "boolean", yylineno, 1, 0, NULL, true);}
                        | CHAR_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symrec[$$] = create_symrec("", "char", yylineno, 1, 0, NULL, true);}
                        | STRING_LITERAL            {$$ = node;
                                                    node++;
                                                    each_symrec[$$] = create_symrec("", "String", yylineno, 1, 0, NULL, true);}
                        | NULL_LITERAL              {$$ = node;
                                                    node++;
                                                    each_symrec[$$] = create_symrec("", "null", yylineno, 1, 0, NULL, true);}
                        | TEXT_BLOCK                {$$ = node;
                                                    node++;
                                                    each_symrec[$$] = create_symrec("", "text_block", yylineno, 1, 0, NULL, true);}
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
                                                                                if(classtable.find(each_symboltable[$1]->info.name)==classtable.end()) {
                                                                                    classtable[each_symboltable[$1]->info.name] = each_symboltable[$2];
                                                                                }
                                                                                else yyerror("Class already exists.");
                                                                                each_symboltable[$2] = NULL;
                                                                                }
                                                                            if(Construct!=NULL){
                                                                                each_symboltable[$$]->info.args = Construct->info.args;
                                                                                Construct = NULL;
                                                                            }
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
                                                                            if(Construct!=NULL){
                                                                                each_symboltable[$$]->info.args = Construct->info.args;
                                                                                Construct = NULL;
                                                                            }}
                        ;
ClassHeader             : CLASS IDENTIFIER                              {$$ = node;
                                                                        node++;
                                                                        each_symboltable[$$] = create_st(create_list($2, 0),create_list($1, 0), yylineno, 2, 0, NULL, true);
                                                                        push_global(each_symboltable[$$]);}
                        | Modifiers CLASS IDENTIFIER                    {$$ = node;
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
                                                                            push_pglobal(each_symboltable[$$]);
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
FieldDeclaration        : Type VariableDeclarators SEMICOLON        {$$ = node;
                                                                    node++;
                                                                    if(each_symrec.find($2)!=each_symrec.end() && (strcmp(each_symrec[$2].datatype, nt[$1]->val) || (each_symrec[$2].dimension != nt[$1]->dim))) yyerror("Type doesn't match.");
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);}
                        | Modifiers Type VariableDeclarators SEMICOLON  {$$ = node;
                                                                    node++;
                                                                    if(each_symrec.find($3)!=each_symrec.end() && (strcmp(each_symrec[$3].datatype, nt[$2]->val) || (each_symrec[$3].dimension != nt[$2]->dim))) yyerror("Type doesn't match.");
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$2], yylineno, 1, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);}
                        ;
VariableDeclarators     : VariableDeclarator                            {$$ = $1;}
                        | VariableDeclarators COMMA VariableDeclarator  {if(each_symrec.find($1)!= each_symrec.end() && each_symrec.find($3)!= each_symrec.end()) cmpsym(each_symrec[$1], each_symrec[$3]);
                                                                        merge(nt[$1],nt[$3]);
                                                                        $$ = $1;}
                        ;
VariableDeclarator      : VariableDeclaratorId                          {$$ = $1;}
                        | VariableDeclaratorId EQ VariableInitializer   {$$ = $1;
                                                                        each_symrec[$$] = each_symrec[$3];}
                        ;
VariableDeclaratorId    : IDENTIFIER                                    {$$ = node;
                                                                        node++;
                                                                        nt[$$] = create_list($1, 0);}
                        | VariableDeclaratorId OSB CSB                  {nt[$1]->dim++;
                                                                        $$ = $1;}
                        ;
VariableInitializer     : Expression                                    {$$ = $1;}
                        | ArrayInitializer                              {$$ = $1;}
                        ;
MethodDeclaration       : MethodHeader MethodBody                   {$$ = $1;
                                                                    if(each_symboltable[$$]->next!=NULL){
                                                                        nlist* k = each_symboltable[$$]->next;
                                                                        pop_global(k);
                                                                        symboltables.push_back(k);
                                                                    }}
                        ;
MethodHeader            : Type MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    push_global(each_symboltable[$2]);
                                                                    each_symboltable[$$]->info.args = args[$2];}          
                        | Modifiers Type MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], nt[$1], yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    push_global(each_symboltable[$3]);
                                                                    each_symboltable[$$]->info.args = args[$3];}
                        | VOID MethodDeclarator                     {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], create_list($1, 0), yylineno, 3, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);
                                                                    push_global(each_symboltable[$2]);
                                                                    each_symboltable[$$]->info.args = args[$2];}
                        | Modifiers VOID MethodDeclarator           {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$3], create_list($2, 0), yylineno, 3, 0, NULL, $1);
                                                                    push_global(each_symboltable[$$]);
                                                                    push_global(each_symboltable[$3]);
                                                                    each_symboltable[$$]->info.args = args[$3];}
                        ;
MethodDeclarator        : SingleName ONB CNB                            {$$ = $1;
                                                                        each_symboltable[$$] = NULL;}
                        | SingleName ONB FormalParameterList CNB        {$$ = $3;
                                                                        list* k = nt[$3];
                                                                        nt[$$] = nt[$1];
                                                                        args[$$] = k;}
                        ;
FormalParameterList     : FormalParameter                               {$$ = $1;}
                        | FormalParameterList COMMA FormalParameter     {merge(nt[$1],nt[$3]);
                                                                        $$ = $1;
                                                                        mergen(each_symboltable[$1],each_symboltable[$3]);}
                        ;
FormalParameter         : Type VariableDeclaratorId                 {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 3, 0, NULL, true);
                                                                    nt[$$] = nt[$1];}            
                        ;
MethodBody              : Block                     {$$ = $1;}
                        | SEMICOLON                 {$$ = node;
                                                    node++;
                                                    each_symboltable[$$] = NULL;}
                        ;           
StaticInitializer       : STATIC Block              {$$ = $2;}
                        ;
ConstructorDeclaration  : ConstructorHeader ConstructorBody         {$$ = $1;
                                                                    pop_global(each_symboltable[$$]);
                                                                    symboltables.push_back(each_symboltable[$$]);
                                                                    each_symboltable[$$] = NULL;}
                        ;
ConstructorHeader       : ConstructorDeclarator                     {$$ = $1;
                                                                    create_cons(nt[$1]->val, "Constructor", yylineno, 3, 0, args[$1], true);
                                                                    push_global(each_symboltable[$1]);}
                        | Modifiers ConstructorDeclarator           {$$ = node;
                                                                    node++;
                                                                    create_cons(nt[$2]->val, "Constructor", yylineno, 3, 0, args[$2], $1);
                                                                    push_global(each_symboltable[$2]);}
                        ;
ConstructorDeclarator   : SingleName ONB CNB                            {$$ = $1;
                                                                        each_symboltable[$$] = NULL;}   
                        | SingleName ONB FormalParameterList CNB        {$$ = $3;
                                                                        list* k = nt[$3];
                                                                        nt[$$] = nt[$1];
                                                                        args[$$] = k;}
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

ArrayInitializer        : OCB CCB                                       {$$ = node;
                                                                        node++;
                                                                        each_symrec[$$] = create_symrec("", "all", yylineno, 1, 1, NULL, true);}
                        | OCB VariableInitializers CCB                  {$$ = $2;
                                                                        each_symrec[$$].dimension++;}
                        | OCB COMMA CCB                                 {$$ = node;
                                                                        node++;
                                                                        each_symrec[$$] = create_symrec("", "all", yylineno, 1, 1, NULL, true);}
                        | OCB VariableInitializers COMMA CCB            {$$ = $2;
                                                                        each_symrec[$$].dimension++;}
                        ;
VariableInitializers    : VariableInitializer                           {$$ = $1;}
                        | VariableInitializers COMMA VariableInitializer    {if(each_symrec.find($1)!= each_symrec.end() && each_symrec.find($3)!= each_symrec.end()) cmpsym(each_symrec[$1], each_symrec[$3]);
                                                                            $$ = $1;}
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
                                                                    if(each_symrec.find($2)!=each_symrec.end() && (strcmp(each_symrec[$2].datatype, nt[$1]->val) || (each_symrec[$2].dimension != nt[$1]->dim))) yyerror("Type doesn't match.");
                                                                    each_symboltable[$$] = create_st(nt[$2], nt[$1], yylineno, 1, 0, NULL, true);
                                                                    push_global(each_symboltable[$$]);}   
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
StatementExpression     : Assignment                                        {$$ = $1;
                                                                            each_symboltable[$$] = NULL;}
                        | PreIncrementExpression                            {$$ = $1;}
                        | PreDecrementExpression                            {$$ = $1;}
                        | PostIncrementExpression                           {$$ = $1;}
                        | PostDecrementExpression                           {$$ = $1;}
                        | MethodInvocation                                  {$$ = $1;}
                        | ClassInstanceCreationExpression                   {$$ = $1;}
                        ;
IfThenStatement         : IF ONB Expression CNB Statement                   {if(strcmp(each_symrec[$3].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                            pop_global(each_symboltable[$5]);
                                                                            symboltables.push_back(each_symboltable[$5]);
                                                                            each_symboltable[$5] = NULL;
                                                                            $$ = $5;}
                        ;
IfThenElseStatement     : IF ONB Expression CNB StatementNoShortIf ELSE Statement   {if(strcmp(each_symrec[$3].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;}
                        ;
IfThenElseStatementNoShortIf    : IF ONB Expression CNB StatementNoShortIf ELSE StatementNoShortIf  {if(strcmp(each_symrec[$3].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;}
                                ;
SwitchStatement         : SWITCH ONB Expression CNB SwitchBlock     {if(strcmp(each_symrec[$3].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                    $$ = $5;}
                        ;
SwitchBlock             : OCB CCB                                   {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;}  
                        | OCB SwitchLabels CCB                      {$$ = $2;}
                        | OCB SwitchBlockStatementGroups CCB                {pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;}
                        | OCB SwitchBlockStatementGroups SwitchLabels CCB   {pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;}
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
WhileStatement          : WHILE ONB Expression CNB Statement                {if(strcmp(each_symrec[$3].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;}   
                        ;
WhileStatementNoShortIf : WHILE ONB Expression CNB StatementNoShortIf       {if(strcmp(each_symrec[$3].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$5]);
                                                                                symboltables.push_back(each_symboltable[$5]);
                                                                                each_symboltable[$5] = NULL;
                                                                                $$ = $5;}
                        ;
DoStatement             : DO Statement WHILE ONB Expression CNB SEMICOLON   {if(strcmp(each_symrec[$5].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$2]);
                                                                                symboltables.push_back(each_symboltable[$2]);
                                                                                each_symboltable[$2] = NULL;
                                                                                $$ = $2;}
                        ;
ForStatement            : FOR ONB SEMICOLON SEMICOLON CNB Statement         {pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;}      
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB Statement {pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB Statement  {if(strcmp(each_symrec[$4].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;}
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB Statement  {if(strcmp(each_symrec[$5].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB Statement   {pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB Statement   {pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {if(strcmp(each_symrec[$4].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$8]);
                                                                                symboltables.push_back(each_symboltable[$8]);
                                                                                each_symboltable[$8] = NULL;
                                                                                $$ = $8;}   
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB Statement    {if(strcmp(each_symrec[$5].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
                        ;
ForStatementNoShortIf   : FOR ONB SEMICOLON SEMICOLON CNB StatementNoShortIf    {pop_global(each_symboltable[$6]);
                                                                                symboltables.push_back(each_symboltable[$6]);
                                                                                each_symboltable[$6] = NULL;
                                                                                $$ = $6;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON CNB StatementNoShortIf    {pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
                        | FOR ONB SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {if(strcmp(each_symrec[$4].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;}
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON CNB StatementNoShortIf {if(strcmp(each_symrec[$5].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
                        | FOR ONB SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf  {pop_global(each_symboltable[$7]);
                                                                                symboltables.push_back(each_symboltable[$7]);
                                                                                each_symboltable[$7] = NULL;
                                                                                $$ = $7;}
                        | FOR ONB ForInit SEMICOLON SEMICOLON ForUpdate CNB StatementNoShortIf  {if(each_symboltable[$3]!=NULL){
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;
                                                                                }
                                                                            }
                        | FOR ONB SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {if(strcmp(each_symrec[$4].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$8]);
                                                                                symboltables.push_back(each_symboltable[$8]);
                                                                                each_symboltable[$8] = NULL;
                                                                                $$ = $8;}
                        | FOR ONB ForInit SEMICOLON Expression SEMICOLON ForUpdate CNB StatementNoShortIf   {if(strcmp(each_symrec[$5].datatype,"boolean")) yyerror("Expression doesn't evalute to boolean.");
                                                                                pop_global(each_symboltable[$3]);
                                                                                symboltables.push_back(each_symboltable[$3]);
                                                                                each_symboltable[$3] = NULL;
                                                                                $$ = $3;}
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
                        | RETURN Expression SEMICOLON               {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;}  
                        ;
ThrowStatement          : THROW Expression SEMICOLON                {$$ = node;
                                                                    node++;
                                                                    each_symboltable[$$] = NULL;} 
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
                                                                    nlist* n = find_in_list(global_tail, nt[$2]->val);
                                                                    if(n!=NULL && n->info.type == 2){
                                                                        each_symrec[$$] = create_symrec("", nt[$2]->val, yylineno, 2, 0, NULL, true);
                                                                    }
                                                                    else yyerror("Class not found.");}  
                                | NEW ClassType ONB ArgumentList CNB    {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$2]->val);
                                                                    if(n!=NULL && n->info.type == 2){
                                                                        each_symrec[$$] = create_symrec("", nt[$2]->val, yylineno, 2, 0, args[$4], true);
                                                                        cmplist(args[$4], n->info.args);
                                                                    }
                                                                    else yyerror("Class not found.");}
                                ;
ArgumentList            : Expression                                {$$ = node;
                                                                    node++;
                                                                    args[$$] = create_list(each_symrec[$1].datatype, each_symrec[$1].dimension);}         
                        | ArgumentList COMMA Expression             {$$ = $1;
                                                                    merge(args[$1],create_list(each_symrec[$3].datatype, each_symrec[$3].dimension));}    
                        ;
ArrayCreationExpression : NEW PrimitiveType DimExprs                {$$ = node;
                                                                    node++;
                                                                    each_symrec[$$] = create_symrec("", nt[$2]->val, yylineno, 1, nt[$3]->dim, NULL, true);} 
                        | NEW PrimitiveType DimExprs Dims           {$$ = node;
                                                                    node++;
                                                                    each_symrec[$$] = create_symrec("", nt[$2]->val, yylineno, 1, nt[$3]->dim + nt[$4]->dim, NULL, true);} 
                        | NEW ClassOrInterfaceType DimExprs         {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$2]->val);
                                                                    if(n!=NULL && n->info.type == 2) each_symrec[$$] = create_symrec("", nt[$2]->val, yylineno, 1, nt[$3]->dim , NULL, true);
                                                                    else yyerror("Class not found.");} 
                        | NEW ClassOrInterfaceType DimExprs Dims    {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$2]->val);
                                                                    if(n!=NULL && n->info.type == 2) each_symrec[$$] = create_symrec("", nt[$2]->val, yylineno, 1, nt[$3]->dim + nt[$4]->dim, NULL, true);
                                                                    else yyerror("Class not found.");} 
                        ;
DimExprs                : DimExpr                                   {$$ = node;
                                                                    node++;
                                                                    nt[$$] = create_list("", 1);}
                        | DimExprs DimExpr                          {$$ = $1;
                                                                    nt[$$]->dim++;}
                        ;
DimExpr                 : OSB Expression CSB                        {if(strcmp(each_symrec[$2].datatype, "int")) yyerror("Expected a int");}
                        ;
Dims                    : OSB CSB                                   {$$ = node;
                                                                    node++;
                                                                    nt[$$] = create_list("", 1);}
                        | Dims OSB CSB                              {$$ = $1;
                                                                    nt[$$]->dim++;}
                        ;   
FieldAccess             : Primary DOT IDENTIFIER                    {$$ = node;
                                                                    node++;
                                                                    string p = strdup(each_symrec[$1].datatype);
                                                                    if(classtable.find(p)!=classtable.end()) {
                                                                        nlist* p_tail = classtable[p];
                                                                        if(p_tail == NULL) yyerror("Variable not found.");
                                                                        else{
                                                                            while(p_tail->next!=NULL) p_tail = p_tail->next;
                                                                            nlist* n = find_in_list(p_tail, $3);
                                                                            if(n!=NULL) each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, n->info.args, n->info.mod);
                                                                            else yyerror("Variable not found");                                                                          
                                                                        }
                                                                    }
                                                                    else yyerror("Class not found.");} 
                        | SUPER DOT IDENTIFIER                      {$$ = node;
                                                                    node++;
                                                                    string p = "super.";
                                                                    char* z = const_cast<char*>(p.c_str());
                                                                    strcat(z,$3);
                                                                    nlist* n = find_in_list(global_tail, z);
                                                                    mergen(n,find_in_list(pglobal_tail,z));
                                                                    if(n!=NULL) each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, n->info.args, n->info.mod);
                                                                    else yyerror("Variable not found");} 
                        ;   
MethodInvocation        : Name ONB CNB                              {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$1]->val);
                                                                    mergen(n,find_in_list(pglobal_tail, nt[$1]->val));
                                                                    if(n!=NULL && (n->info.type == 3)) {
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, NULL, n->info.mod);
                                                                        cmpsym(each_symrec[$$],n->info);
                                                                    }   
                                                                    else yyerror("Method not found");} 
                        | Name ONB ArgumentList CNB                 {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$1]->val);
                                                                    mergen(n,find_in_list(pglobal_tail, nt[$1]->val));
                                                                    if(n!=NULL && (n->info.type == 3)) {
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, args[$3], n->info.mod);
                                                                        cmpsym(each_symrec[$$],n->info);
                                                                    }
                                                                    else yyerror("Method not found");} 
                        | Primary DOT IDENTIFIER ONB CNB            {$$ = node;
                                                                    node++;
                                                                    string p = strdup(each_symrec[$1].datatype);
                                                                    if(classtable.find(p)!=classtable.end()) {
                                                                        nlist* p_tail = classtable[p];
                                                                        if(p_tail == NULL) yyerror("Method not found.");
                                                                        else{
                                                                            while(p_tail->next!=NULL) p_tail = p_tail->next;
                                                                            nlist* n = find_in_list(p_tail, $3);
                                                                            if(n!=NULL && (n->info.type == 3)) {
                                                                                each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, NULL, n->info.mod);
                                                                                cmpsym(each_symrec[$$],n->info);
                                                                            }
                                                                            else yyerror("Method not found");                                                                          
                                                                        }
                                                                    }
                                                                    else yyerror("Class not found.");}
                        | Primary DOT IDENTIFIER ONB ArgumentList CNB   {$$ = node;
                                                                    node++;
                                                                    string p = strdup(each_symrec[$1].datatype);
                                                                    if(classtable.find(p)!=classtable.end()) {
                                                                        nlist* p_tail = classtable[p];
                                                                        if(p_tail == NULL) yyerror("Method not found.");
                                                                        else{
                                                                            while(p_tail->next!=NULL) p_tail = p_tail->next;
                                                                            nlist* n = find_in_list(p_tail, $3);
                                                                            if(n!=NULL && (n->info.type == 3)) {
                                                                                each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, args[$5], n->info.mod);
                                                                                cmpsym(each_symrec[$$],n->info);
                                                                            }
                                                                            else yyerror("Method not found");                                                                          
                                                                        }
                                                                    }
                                                                    else yyerror("Class not found.");}
                        | SUPER DOT IDENTIFIER ONB CNB              {$$ = node;
                                                                    node++;
                                                                    string p = "super.";
                                                                    char* z = const_cast<char*>(p.c_str());
                                                                    strcat(z,$3);
                                                                    nlist* n = find_in_list(global_tail, z);
                                                                    mergen(n,find_in_list(pglobal_tail,z));
                                                                    if(n!=NULL && (n->info.type == 3)) {
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, NULL, n->info.mod);
                                                                        cmpsym(each_symrec[$$],n->info);
                                                                    }
                                                                    else yyerror("Variable not found");} 
                        | SUPER DOT IDENTIFIER ONB ArgumentList CNB {$$ = node;
                                                                    node++;
                                                                    string p = "super.";
                                                                    char* z = const_cast<char*>(p.c_str());
                                                                    strcat(z,$3);
                                                                    nlist* n = find_in_list(global_tail, z);
                                                                    mergen(n,find_in_list(pglobal_tail,z));
                                                                    if(n!=NULL && (n->info.type == 3)) {
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, args[$5], n->info.mod);
                                                                        cmpsym(each_symrec[$$],n->info);
                                                                    }
                                                                    else yyerror("Variable not found");} 
                        ;
ArrayAccess             : Name OSB Expression CSB                   {$$ = node;
                                                                    node++;
                                                                    if(strcmp(each_symrec[$3].datatype, "int")) yyerror("Expected a int");
                                                                    nlist* n = find_in_list(global_tail, nt[$1]->val);
                                                                    mergen(n,find_in_list(pglobal_tail, nt[$1]->val));
                                                                    if(n!=NULL) {
                                                                        if(n->info.dimension-1 >= 0)
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension-1, n->info.args, n->info.mod);
                                                                        else
                                                                        yyerror("Array dimensions doesn't match.");
                                                                    }
                                                                    else yyerror("Variable not found");}       
                        | PrimaryNoNewArray OSB Expression CSB      {$$ = node;
                                                                    node++;
                                                                    if(strcmp(each_symrec[$3].datatype, "int")) yyerror("Expected a int");
                                                                    if((each_symrec[$1].dimension-1)>=0) each_symrec[$1].dimension--;
                                                                    else yyerror("Array dimensions doesn't match.");}
                        ;
PostfixExpression       : Primary                                   {$$=$1;}
                        | Name                                      {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$1]->val);
                                                                    mergen(n,find_in_list(pglobal_tail, nt[$1]->val));
                                                                    if(n!=NULL) {
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, n->info.args, n->info.mod);
                                                                    }   
                                                                    else yyerror("Variable not found");} 
                        | PostIncrementExpression                   {$$=$1;}
                        | PostDecrementExpression                   {$$=$1;}
                        ;
PostIncrementExpression : PostfixExpression INC                     {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1) $$ = $1;
                                                                    else yyerror("Expected a Primitive datatype."); } 
                        ;   
PostDecrementExpression : PostfixExpression DEC                     {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1) $$ = $1;
                                                                    else yyerror("Expected a Primitive datatype."); } 
                        ;
UnaryExpression         : PreIncrementExpression                    {$$ = $1;}
                        | PreDecrementExpression                    {$$ = $1;}
                        | PLUS UnaryExpression                      {$$ = $2;}
                        | MINUS UnaryExpression                     {$$ = $2;}
                        | UnaryExpressionNotPlusMinus               {$$ = $1;}
                        ;
PreIncrementExpression  : INC UnaryExpression                       {if(types.find(each_symrec[$2].datatype)!=types.end() && types[each_symrec[$2].datatype]==1) $$ = $2;
                                                                    else yyerror("Expected a type Primitive datatype."); }  
                        ;
PreDecrementExpression  : DEC UnaryExpression                       {if(types.find(each_symrec[$2].datatype)!=types.end() && types[each_symrec[$2].datatype]==1) $$ = $2;
                                                                    else yyerror("Expected a type Primitive datatype."); }  
                        ;
UnaryExpressionNotPlusMinus : PostfixExpression                     {$$ = $1;}
                            | NEG UnaryExpression                   {if(!strcmp(each_symrec[$2].datatype,"int")) $$ = $2;
                                                                    else yyerror("Expected a type int."); } 
                            | NOT UnaryExpression                   {if(!strcmp(each_symrec[$2].datatype,"boolean")) $$ = $2;
                                                                    else yyerror("Expected a type boolean."); } 
                            | CastExpression                        {$$ = $1;}
                            ;
CastExpression          : ONB PrimitiveType CNB UnaryExpression     {if(types.find(each_symrec[$4].datatype)!=types.end() && types[each_symrec[$4].datatype]==1 && types.find(nt[$2]->val)!=types.end() && types[nt[$2]->val]==1) {
                                                                        each_symrec[$4].datatype = nt[$2]->val;
                                                                        $$ = $4;
                                                                    }}
                        ;
MultiplicativeExpression    : UnaryExpression                                   {$$ = $1;}
                            | MultiplicativeExpression STAR UnaryExpression     {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) $$ = $1;
                                                                                else yyerror("Type doesn't match.");}
                            | MultiplicativeExpression DIV UnaryExpression      {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) $$ = $1;
                                                                                else yyerror("Type doesn't match.");} 
                            | MultiplicativeExpression MOD UnaryExpression      {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) $$ = $1;
                                                                                else yyerror("Type doesn't match.");} 
                            ;
AdditiveExpression      : MultiplicativeExpression                          {$$ = $1;}
                        | AdditiveExpression PLUS MultiplicativeExpression  {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) $$ = $1;
                                                                            else if(!strcmp(each_symrec[$1].datatype,"String")) $$ = $1;
                                                                            else if(!strcmp(each_symrec[$3].datatype,"String")) $$ = $3;
                                                                            else yyerror("Type doesn't match.");} 
                        | AdditiveExpression MINUS MultiplicativeExpression {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) $$ = $1;
                                                                            else yyerror("Type doesn't match.");}
                        ;
ShiftExpression         : AdditiveExpression                            {$$ = $1;}
                        | ShiftExpression SHIFT AdditiveExpression      {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) $$ = $1;
                                                                        else yyerror("Type doesn't match.");}  
                        ;
RelationalExpression    : ShiftExpression                               {$$ = $1;}
                        | RelationalExpression RELGL ShiftExpression    {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) {
                                                                            $$ = $1;
                                                                            each_symrec[$$].datatype = "boolean";
                                                                        }   
                                                                        else yyerror("Type doesn't match.");} 
                        | RelationalExpression INSTANCEOF ReferenceType {if(types.find(each_symrec[$1].datatype)!=types.end() && types[each_symrec[$1].datatype]==1 && types.find(each_symrec[$3].datatype)!=types.end() && types[each_symrec[$3].datatype]==1) {
                                                                            $$ = $1;
                                                                            each_symrec[$$].datatype = "boolean";
                                                                        }
                                                                        else yyerror("Type doesn't match.");} 
                        ;
EqualityExpression      : RelationalExpression                              {$$ = $1;}
                        | EqualityExpression RELEQ RelationalExpression     {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                            $$ = $1;}
                        | EqualityExpression RELNOTEQ RelationalExpression  {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                            $$ = $1;} 
                        ;
AndExpression           : EqualityExpression                        {$$ = $1;}
                        | AndExpression AND EqualityExpression      {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                    $$ = $1;} 
                        ;
ExclusiveOrExpression   : AndExpression                             {$$ = $1;}
                        | ExclusiveOrExpression UP AndExpression    {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                    $$ = $1;} 
                        ;
InclusiveOrExpression   : ExclusiveOrExpression                     {$$ =$1;}
                        | InclusiveOrExpression OR ExclusiveOrExpression    {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                            $$ = $1;}  
                        ;
ConditionalAndExpression    : InclusiveOrExpression                 {$$ = $1;}
                            | ConditionalAndExpression RELAND InclusiveOrExpression {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                                    $$ = $1;}  
                            ;
ConditionalOrExpression : ConditionalAndExpression                                          {$$ = $1;}
                        | ConditionalOrExpression RELOR ConditionalAndExpression            {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                                            $$ = $1;} 
                        ;
ConditionalExpression   : ConditionalOrExpression                                           {$$ = $1;}
                        | ConditionalOrExpression QM Expression COLON ConditionalExpression {cmpsym(each_symrec[$3],each_symrec[$5]);
                                                                                            $$ = $5;} 
                        ;
AssignmentExpression    : ConditionalExpression         {$$ = $1;} 
                        | Assignment                    {$$ = $1;} 
                        ;
Assignment              : LeftHandSide Assignment_Operators AssignmentExpression            {cmpsym(each_symrec[$1],each_symrec[$3]);
                                                                                            $$ = $1;}
                        ;
Assignment_Operators    : ASSIGNMENT_OPERATOR                       
                        | EQ                                        
                        ;
LeftHandSide            : Name                                      {$$ = node;
                                                                    node++;
                                                                    nlist* n = find_in_list(global_tail, nt[$1]->val);
                                                                    mergen(n,find_in_list(pglobal_tail, nt[$1]->val));
                                                                    if(n!=NULL) {
                                                                        each_symrec[$$] = create_symrec("", n->info.datatype, yylineno, n->info.type, n->info.dimension, n->info.args, n->info.mod);
                                                                    }   
                                                                    else yyerror("Variable not found");}
                        | FieldAccess                               {$$ = $1;}  
                        | ArrayAccess                               {$$ = $1;}
                        ;
Expression              : AssignmentExpression                      {$$ = $1;} 
                        ;
ConstantExpression      : Expression                                {$$ = $1;} 
                        ;

%%                    


int main (int argc, char** argv) {
    fout.open("output.3ac");
    types["int"] = 1;   types1.insert("int");           types2.insert("int");
    types["long"] = 1;  types1.insert("long");          types2.insert("long"); 
    types["char"] = 1;  types1.insert("char");          types2.insert("char");
    types["float"] = 1;     types1.insert("float");     types3.insert("float");
    types["double"] = 1;    types1.insert("double");    types3.insert("double");
    types["String"] = 2;
    types["class"] = 2;
    types["interface"] = 2;
    types["void"] = 2;
    types["boolean"] = 2;

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
    outfile.close();
    fout.close();
	return 0;
}

void yyerror (char *s) {fprintf (stderr, "ERROR: %s \nIn Line number:%d\n", s, yylineno); exit(0);}