/* A Bison parser, made by GNU Bison 3.5.1.  */

/* Bison interface for Yacc-like parsers in C

   Copyright (C) 1984, 1989-1990, 2000-2015, 2018-2020 Free Software Foundation,
   Inc.

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */

/* As a special exception, you may create a larger work that contains
   part or all of the Bison parser skeleton and distribute that work
   under terms of your choice, so long as that work isn't itself a
   parser generator using the skeleton or a modified version thereof
   as a parser skeleton.  Alternatively, if you modify or redistribute
   the parser skeleton itself, you may (at your option) remove this
   special exception, which will cause the skeleton and the resulting
   Bison output files to be licensed under the GNU General Public
   License without this special exception.

   This special exception was added by the Free Software Foundation in
   version 2.2 of Bison.  */

/* Undocumented macros, especially those whose name start with YY_,
   are private implementation details.  Do not rely on them.  */

#ifndef YY_YY_JAVA_PARSER_TAB_H_INCLUDED
# define YY_YY_JAVA_PARSER_TAB_H_INCLUDED
/* Debug traces.  */
#ifndef YYDEBUG
# define YYDEBUG 1
#endif
#if YYDEBUG
extern int yydebug;
#endif

/* Token type.  */
#ifndef YYTOKENTYPE
# define YYTOKENTYPE
  enum yytokentype
  {
    INTEGRALTYPE = 258,
    FLOATINGPOINTTYPE = 259,
    BOOL_LITERAL = 260,
    ASSIGNMENT_OPERATOR = 261,
    SHIFT = 262,
    RELGL = 263,
    INT_LITERAL = 264,
    FLOAT_LITERAL = 265,
    CHAR_LITERAL = 266,
    STRING_LITERAL = 267,
    TEXT_BLOCK = 268,
    IDENTIFIER = 269,
    NULL_LITERAL = 270,
    BOOLEAN = 271,
    EXTENDS = 272,
    SUPER = 273,
    INTERFACE = 274,
    PUBLIC = 275,
    PROTECTED = 276,
    PRIVATE = 277,
    ABSTRACT = 278,
    STATIC = 279,
    FINAL = 280,
    DEFAULT = 281,
    CLASS = 282,
    IMPLEMENTS = 283,
    THROWS = 284,
    THIS = 285,
    SYNCHRONIZED = 286,
    VOID = 287,
    SWITCH = 288,
    CONTINUE = 289,
    FOR = 290,
    NEW = 291,
    IF = 292,
    DO = 293,
    BREAK = 294,
    THROW = 295,
    ELSE = 296,
    CASE = 297,
    INSTANCEOF = 298,
    RETURN = 299,
    TRANSIENT = 300,
    CATCH = 301,
    TRY = 302,
    FINALLY = 303,
    VOLATILE = 304,
    NATIVE = 305,
    WHILE = 306,
    INC = 307,
    DEC = 308,
    RELAND = 309,
    RELOR = 310,
    RELEQ = 311,
    RELNOTEQ = 312,
    PACKAGE = 313,
    IMPORT = 314,
    SEMICOLON = 315,
    DOT = 316,
    STAR = 317,
    OSB = 318,
    CSB = 319,
    OCB = 320,
    CCB = 321,
    ONB = 322,
    CNB = 323,
    COMMA = 324,
    COLON = 325,
    PLUS = 326,
    MINUS = 327,
    NEG = 328,
    NOT = 329,
    DIV = 330,
    MOD = 331,
    AND = 332,
    UP = 333,
    OR = 334,
    QM = 335,
    EQ = 336
  };
#endif

/* Value type.  */
#if ! defined YYSTYPE && ! defined YYSTYPE_IS_DECLARED
union YYSTYPE
{
#line 18 "java_parser.y"

    int num;
    char id;
    char* str;

#line 145 "java_parser.tab.h"

};
typedef union YYSTYPE YYSTYPE;
# define YYSTYPE_IS_TRIVIAL 1
# define YYSTYPE_IS_DECLARED 1
#endif


extern YYSTYPE yylval;

int yyparse (void);

#endif /* !YY_YY_JAVA_PARSER_TAB_H_INCLUDED  */
