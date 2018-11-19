%error-verbose
%locations
%{
#include "stdio.h"
#include "math.h"
#include "string.h"
#include "def.h"
extern int yylineno;
extern char *yytext;
extern FILE *yyin;
void yyerror(const char* fmt, ...);
void display(struct node *,int);
%}

%union {
	int    type_int;
	float  type_float;
	char   type_char;
	char   type_id[32];
	struct node *ptr;
};

//  %type 定义非终结符的语义值类型
%type  <ptr> program  ExpS ExtDefList ExtDef  Specifier ExtDecList FuncDec CompSt VarList VarDec ParamDec Stmt StmList DefList Def DecList Dec Exp Args StructSpecifier OptTag Tag

//% token 定义终结符的语义值类型
%token <type_int> INT              //指定INT的语义值是type_int，有词法分析得到的数值
%token <type_id> ID RELOP TYPE  //指定ID,RELOP 的语义值是type_id，有词法分析得到的标识符字符串
%token <type_float> FLOAT         //指定ID的语义值是type_id，有词法分析得到的标识符字符串
%token <type_char>CHAR

%token LP RP LB RB LC RC SEMI COMMA INCRE DECRE COMPADD COMPSUB COMPMUL COMPDIV  STRUCT //用bison对该文件编译时，带参数-d，生成的exp.tab.h中给这些单词进行编码，可在lex.l中包含parser.tab.h使用这些单词种类码
%token PLUS MINUS STAR DIV ASSIGNOP AND OR NOT IF ELSE WHILE RETURN FOR

%left ASSIGNOP COMPADD COMPSUB COMPMUL COMPDIV
%left OR
%left AND
%left RELOP
%left PLUS MINUS
%left STAR DIV
%left POST
%right PRE
%right UMINUS NOT


%nonassoc LOWER_THEN_ELSE LOW
%nonassoc ELSE HIGH

%%

program: ExtDefList    { /*display($1,0);*/ semantic_Analysis0($1);} /*显示语法树,语义分析*/
         ; 
ExtDefList: {$$=NULL;}
          | ExtDef ExtDefList {$$=mknode(EXT_DEF_LIST,$1,$2,NULL,yylineno);}   //每一个EXTDEFLIST的结点，其第1棵子树对应一个外部变量声明或函数
          ;  
ExtDef:   Specifier ExtDecList SEMI   {$$=mknode(EXT_VAR_DEF,$1,$2,NULL,yylineno);}   //该结点对应一个外部变量声明
		 |Specifier SEMI  {$$=mknode(StructDec,$1,NULL,NULL,yylineno);}               //结构体声明 
         |Specifier FuncDec CompSt    {$$=mknode(FUNC_DEF,$1,$2,$3,yylineno);}         //该结点对应一个函数定义
         | error SEMI   {$$=NULL; }
         ;
Specifier:  TYPE    {$$=mknode(TYPE,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);$$->type=!strcmp($1,"int")?INT:FLOAT;}   
		|StructSpecifier	{$$=mknode(StructDef,$1,NULL,NULL,yylineno);}
		;
StructSpecifier: STRUCT OptTag LC DefList RC  {$$=mknode(StructSpecifier,$2,$4,NULL,yylineno);}
		|STRUCT Tag {$$=mknode(StructSpecifier,$2,NULL,NULL,yylineno);}
		;
OptTag: ID {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
		|  {$$=NULL;}
		;
Tag: ID {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
	;
ExtDecList:  VarDec      {$$ = mknode(ArrDef, $1, NULL, NULL, yylineno);}       /*每一个EXT_DECLIST的结点，其第一棵子树对应一个变量名(ID类型的结点),第二棵子树对应剩下的外部变量名*/
           | VarDec COMMA ExtDecList {$$=mknode(EXT_DEC_LIST,$1,$3,NULL,yylineno);}
           ;  
VarDec:  ID    %prec LOWER_THEN_ELSE      {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
		| VarDec LB INT RB {$$ = mknode(ArrDec, $1, NULL, NULL, yylineno); $$->type_int = $3;}//ID结点，标识符符号串存放结点的type_id
         ;
FuncDec: ID LP VarList RP   {$$=mknode(FUNC_DEC,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//函数名存放在$$->type_id
		|ID LP  RP   {$$=mknode(FUNC_DEC,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}//函数名存放在$$->type_id

        ;  
VarList: ParamDec  {$$=mknode(PARAM_LIST,$1,NULL,NULL,yylineno);}
        | ParamDec COMMA  VarList  {$$=mknode(PARAM_LIST,$1,$3,NULL,yylineno);}
        ;
ParamDec: Specifier VarDec         {$$=mknode(PARAM_DEC,$1,$2,NULL,yylineno);}
         ;

CompSt: LC DefList StmList RC    {$$=mknode(COMP_STM,$2,$3,NULL,yylineno);}
       ;
StmList: {$$=NULL; }  
        | Stmt StmList  {$$=mknode(STM_LIST,$1,$2,NULL,yylineno);}
        ;
Stmt:   Exp SEMI    {$$=mknode(EXP_STMT,$1,NULL,NULL,yylineno);}
      | CompSt      {$$=$1;}      //复合语句结点直接最为语句结点，不再生成新的结点
      | RETURN Exp SEMI   {$$=mknode(RETURN,$2,NULL,NULL,yylineno);}
      | IF LP Exp RP Stmt %prec LOWER_THEN_ELSE   {$$=mknode(IF_THEN,$3,$5,NULL,yylineno);}
      | IF LP Exp RP Stmt ELSE Stmt   {$$=mknode(IF_THEN_ELSE,$3,$5,$7,yylineno);}
      | WHILE LP Exp RP Stmt {$$=mknode(WHILE,$3,$5,NULL,yylineno);}
      | FOR LP ExpS RP Stmt {$$=mknode(FOR,$3,$5,NULL,yylineno);}
      | error SEMI {$$=NULL;}
      ;
ExpS:   Exp SEMI Exp SEMI Exp {$$=mknode(ForExp,$1,$3,$5,yylineno);}
  
DefList: {$$=NULL; }
        | Def DefList {$$=mknode(DEF_LIST,$1,$2,NULL,yylineno);}
        ;
Def:    Specifier DecList SEMI {$$=mknode(VAR_DEF,$1,$2,NULL,yylineno);}
	   ;
DecList: Dec  {$$=mknode(DEC_LIST,$1,NULL,NULL,yylineno);}
       | Dec COMMA DecList  {$$=mknode(DEC_LIST,$1,$3,NULL,yylineno);}
	   ;
Dec:     VarDec  {$$=$1;}
       | VarDec ASSIGNOP Exp  {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}
       ;
Exp:    Exp ASSIGNOP Exp {$$=mknode(ASSIGNOP,$1,$3,NULL,yylineno);strcpy($$->type_id,"ASSIGNOP");}//$$结点type_id空置未用，正好存放运算符
      | Exp AND Exp   {$$=mknode(AND,$1,$3,NULL,yylineno);strcpy($$->type_id,"AND");}
      | Exp OR Exp    {$$=mknode(OR,$1,$3,NULL,yylineno);strcpy($$->type_id,"OR");}
      | Exp RELOP Exp {$$=mknode(RELOP,$1,$3,NULL,yylineno);strcpy($$->type_id,$2);}  //词法分析关系运算符号自身值保存在$2中
      | Exp PLUS Exp  {$$=mknode(PLUS,$1,$3,NULL,yylineno);strcpy($$->type_id,"PLUS");}
      | Exp MINUS Exp {$$=mknode(MINUS,$1,$3,NULL,yylineno);strcpy($$->type_id,"MINUS");}
      | Exp STAR Exp  {$$=mknode(STAR,$1,$3,NULL,yylineno);strcpy($$->type_id,"STAR");}
      | Exp DIV Exp   {$$=mknode(DIV,$1,$3,NULL,yylineno);strcpy($$->type_id,"DIV");}
	  | Exp COMPADD Exp  {$$=mknode(COMPADD,$1,$3,NULL,yylineno);strcpy($$->type_id,"COMPADD");}
      | Exp COMPSUB Exp {$$=mknode(COMPSUB,$1,$3,NULL,yylineno);strcpy($$->type_id,"COMPSUB");}
      | Exp COMPMUL Exp  {$$=mknode(COMPMUL,$1,$3,NULL,yylineno);strcpy($$->type_id,"COMPMUL");}
      | Exp COMPDIV Exp   {$$=mknode(COMPDIV,$1,$3,NULL,yylineno);strcpy($$->type_id,"COMPDIV");}
      | LP Exp RP     {$$=$2;}
      | MINUS Exp %prec UMINUS   {$$=mknode(UMINUS,$2,NULL,NULL,yylineno);strcpy($$->type_id,"UMINUS");}
      | NOT Exp       {$$=mknode(NOT,$2,NULL,NULL,yylineno);strcpy($$->type_id,"NOT");}
      | ID LP Args RP {$$=mknode(FUNC_CALL,$3,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | ID LP RP      {$$=mknode(FUNC_CALL,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | Exp LB Exp RB    {$$ = mknode(ArrRef, $1, $3, NULL, yylineno);}
      | ID %prec ELSE            {$$=mknode(ID,NULL,NULL,NULL,yylineno);strcpy($$->type_id,$1);}
      | INT           {$$=mknode(INT,NULL,NULL,NULL,yylineno);$$->type_int=$1;$$->type=INT;}
      | FLOAT         {$$=mknode(FLOAT,NULL,NULL,NULL,yylineno);$$->type_float=$1;$$->type=FLOAT;}
	  | CHAR          {$$=mknode(CHAR,NULL,NULL,NULL,yylineno);$$->type_char=$1;$$->type=CHAR;}
	  | Exp INCRE %prec POST {$$ = mknode(PostIncre, $1, NULL, NULL, yylineno); /*strcpy($$->type_id, $1);*/}
	  | Exp DECRE %prec POST {$$ = mknode(PostDecre, $1, NULL, NULL, yylineno); /*strcpy($$->type_id, $1); */}
	  | INCRE Exp %prec PRE{$$ = mknode(PreIncre, $2, NULL, NULL, yylineno);  /*strcpy($$->type_id, $2);*/}
	  | DECRE Exp %prec PRE{$$ = mknode(PreDecre, $2, NULL, NULL, yylineno);  /*strcpy($$->type_id, $2);*/}
      ;    
Args:    Exp COMMA Args    {$$ = mknode(ARGS,$1,$3,NULL,yylineno);}
       | Exp               {$$ = mknode(ARGS,$1,NULL,NULL,yylineno);}
       ;
       
%%

int main(int argc, char *argv[]){
	yyin=fopen(argv[1],"r");
	if (!yyin) return 0;
	yylineno=1;
	yyparse();
	return 0;
	}

#include<stdarg.h>
void yyerror(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    fprintf(stderr, "Grammar Error at Line %d Column %d: ", yylloc.first_line,yylloc.first_column);
    vfprintf(stderr, fmt, ap);
    fprintf(stderr, ".\n");
}
