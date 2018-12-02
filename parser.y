%{

#include<stdio.h>
//#include "stack.h"
#include "tabsym.h"
extern int yylex();
extern int yylineno;


void yyerror (char*);

tabsym tablaSimbolos;

int tipo;
%}

%union{
	char *id;
	struct{
		int ival;
		double dval;
		int type;
	}numero;
	int type;
}


%token INT FLOAT DOUBLE CHAR VOID STRUCT FUNC
%token IF DO WHILE FOR SWITCH CASE BREAK DEFAULT RETURN PRINT
%token TRUE FALSE
%token COMA PYC DP PTO
%token<id> ID
%token CADENA CARACTER
%token<numero> NUMERO

%right ASIG
%left OR
%left AND
%left IGUAL DISTINTO
%left GT LT LE GE
%left MAS MENOS
%left MUL DIV MOD
%right NEG
%nonassoc LPAR RPAR RKEY LKEY LCOR RCOR
%nonassoc IFX//se le da la mayor precendencia para resolver la ambiguedad de las producciones de if e if else
%nonassoc ELSE//se le da la mayor precedencia


%type<type> tipo
%start program

%%

program: {init();}declaraciones funciones{printf("P->DF\n");};

declaraciones: tipo{tipo=$1;} lista PYC declaraciones| ; 

tipo: INT{$$=0;} 
	| FLOAT{$$=1;} 
	| DOUBLE{$$=2;} 
	| CHAR {$$=3;}
	| VOID {$$=4;}
	| STRUCT LKEY declaraciones RKEY{$$=5;};

lista: lista COMA ID arreglo |ID arreglo;
arreglo: LCOR NUMERO RCOR arreglo|;
funciones:FUNC tipo ID LPAR argumentos RPAR LKEY declaraciones sentencias RKEY funciones | ;
argumentos: lista_argumentos |;
lista_argumentos: lista_argumentos COMA tipo ID parte_arreglo | tipo ID parte_arreglo;
parte_arreglo: LCOR RCOR parte_arreglo|;
sentencias: sentencia sentencias | sentencia; 
sentencia: IF LPAR condicion RPAR sentencia %prec IFX
          |IF LPAR condicion RPAR sentencia ELSE sentencia 
          |WHILE LPAR condicion RPAR sentencia
          |DO sentencia WHILE LPAR condicion RPAR PYC
          |FOR LPAR sentencia PYC condicion PYC sentencia RPAR sentencia
          |parte_izq ASIG expresion PYC
          |RETURN expresion PYC
          |RETURN PYC
          |LKEY sentencias RKEY
          |SWITCH LPAR expresion RPAR LKEY casos predeterminado RKEY
          |PRINT expresion PYC;

casos: CASE NUMERO DP sentencias casos | ;
predeterminado: DEFAULT DP sentencias | ;
parte_izq: ID | var_arreglo | ID PTO ID;
var_arreglo:ID LCOR expresion RCOR | var_arreglo LCOR expresion RCOR;
expresion: expresion MAS expresion
          |expresion MENOS expresion
          |expresion MUL expresion
          |expresion DIV expresion
          |expresion MOD expresion
          |LPAR expresion RPAR
          |parte_izq
          |CADENA
          |NUMERO
          |CARACTER
          |ID LPAR parametros RPAR;

condicion: condicion OR condicion
          |condicion AND condicion
          |NEG condicion
          |expresion relacional expresion
          |LPAR condicion RPAR
          |TRUE
          |FALSE;
          
parametros: | lista_param;
lista_param:lista_param COMA expresion | expresion;
relacional:GT|LT|GE|LE|DISTINTO|IGUAL;

%%
void yyerror (char*){
	printf("%s, linea: %d", s,yylineno);

}
void init(){
//funcion que creoa las pilas de las tablas de tipos y de simbolos
//inicia las pilas de las etiquetas (NEXT, TRUE,FALSE)
}

