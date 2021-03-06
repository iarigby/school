%baseclass-preinclude "semantics.h"

%lsp-needed

%union
{
  std::string *name;
  type *expr_type;
}

%token T_PROGRAM
%token T_BEGIN
%token T_END
%token T_INTEGER 
%token T_BOOLEAN
%token T_SKIP
%token T_IF
%token T_THEN
%token T_ELSE
%token T_ENDIF
%token T_WHILE
%token T_DO
%token T_DONE
%token T_READ
%token T_WRITE
%token T_SEMICOLON
%token T_ASSIGN
%token T_OPEN
%token T_CLOSE
%token T_NUM
%token T_TRUE
%token T_FALSE
%token <name> T_ID

%left T_OR T_AND
%left T_EQ
%left T_LESS T_GR
%left T_ADD T_SUB
%left T_MUL T_DIV T_MOD
%nonassoc T_NOT

%type <expr_type> expression

%start program
%%

program:
    T_PROGRAM T_ID declarations T_BEGIN statements T_END
    {
        std::cout << "start -> T_PROGRAM T_ID declarations T_BEGIN statements T_END" << std::endl;
    }
;

declarations:
    // empty
    {
        //std::cout << "declarations -> epsilon" << std::endl;
    }
|
    declaration declarations
    {
        //std::cout << "declarations -> declaration declarations" << std::endl;
    }
;

declaration:
    T_INTEGER T_ID T_SEMICOLON
    {
       if( symbol_table.count(*$2) > 0 )
        {
          std::stringstream ss;
          ss << "Re-declared variable: " << *$2 << ".\n"
          << "Line of previous declaration: " << symbol_table[*$2].decl_row << std::endl;
          error( ss.str().c_str() );
        }
        symbol_table[*$2] = var_data( d_loc__.first_line, integer );
        std::cout << "declared variable " << *$2 << std::endl; 
    }
|
    T_BOOLEAN T_ID T_SEMICOLON
    {
        if( symbol_table.count(*$2) > 0 )
        {
          std::stringstream ss;
          ss << "Re-declared variable: " << *$2 << ".\n"
          << "Line of previous declaration: " << symbol_table[*$2].decl_row << std::endl;
          error( ss.str().c_str() );
        }
        symbol_table[*$2] = var_data( d_loc__.first_line, boolean );
        std::cout << "declared variable " << *$2 << std::endl; 
    }
;

statements:
    statement
    {
        std::cout << "statements -> statement" << std::endl;
    }
|
    statement statements
    {
        std::cout << "statements -> statement statements" << std::endl;
    }
;

statement:
    T_SKIP T_SEMICOLON
    {
        std::cout << "statement -> T_SKIP T_SEMICOLON" << std::endl;
    }
|
    assignment
    {
        std::cout << "statement -> assignment" << std::endl;
    }
|
    read
    {
        std::cout << "statement -> read" << std::endl;
    }
|
    write
    {
        std::cout << "statement -> write" << std::endl;
    }
|
    branch
    {
        std::cout << "statement -> branch" << std::endl;
    }
|
    loop
    {
        std::cout << "statement -> loop" << std::endl;
    }
;

assignment:
    T_ID T_ASSIGN expression T_SEMICOLON
    {
        if (symbol_table.count(*$1) > 0 ) {
          std::cout << "assignment -> T_ID T_ASSIGN expression T_SEMICOLON" << std::endl;
        } else {
          std::stringstream ss;
          ss << "asssignment to undeclared variable: " << *$1 << ".\n";
          error( ss.str().c_str() ); 
        }
        
    }
;

read:
    T_READ T_OPEN T_ID T_CLOSE T_SEMICOLON
    {
        if (symbol_table.count(*$3) > 0 ) {
          std::cout << "read -> T_READ T_OPEN T_ID T_CLOSE T_SEMICOLON" << std::endl;
        } else {
          std::stringstream ss;
          ss << "read of undeclared variable: " << *$3 << ".\n";
          error( ss.str().c_str() ); 
        }
    }
;

write:
    T_WRITE T_OPEN expression T_CLOSE T_SEMICOLON
    {
        std::cout << "write -> T_WRITE T_OPEN expression T_CLOSE T_SEMICOLON" << std::endl;
    }
;

branch:
    T_IF expression T_THEN statements T_ENDIF
    {
        std::cout << "branch -> T_IF expression T_THEN statements T_ENDIF" << std::endl;
    }
|
    T_IF expression T_THEN statements T_ELSE statements T_ENDIF
    {
        std::cout << "branch -> T_IF expression T_THEN statements T_ELSE statements T_ENDIF" << std::endl;
    }
;

loop:
    T_WHILE expression T_DO statements T_DONE
    {
        std::cout << "loop -> T_WHILE expression T_DO statements T_DONE" << std::endl;
    }
;

expression:
    T_NUM
    {
        $$ = new type(integer);
        std::cout << "expression -> T_NUM" << std::endl;
    }
|
    T_TRUE
    {
        $$ = new type(boolean);
        std::cout << "expression -> T_TRUE" << std::endl;
    }
|
    T_FALSE
    {
        $$ = new type(boolean);
        std::cout << "expression -> T_FALSE" << std::endl;
    }
|
    T_ID
    {
        if (symbol_table.count(*$1) > 0 ) {
          std::cout << "expression -> T_ID" << std::endl;
           $$ = new type (symbol_table[*$1].var_type);
        } else {
          std::stringstream ss;
          ss << "use of undeclared variable in expressin: " << *$1 << ".\n";
          error( ss.str().c_str() ); 
        }
    }
|
    expression T_ADD expression
    {
        if(*$1 != integer || *$3 != integer)
        {
           std::stringstream ss;
           ss << d_loc__.first_line << ": Type error in addition." << std::endl;
           error( ss.str().c_str() );
        }
        $$ = new type(integer);
        std::cout << "expression -> expression T_ADD expression" << std::endl;
    }
|
    expression T_SUB expression
    {
        std::cout << "expression -> expression T_SUB expression" << std::endl;
    }
|
    expression T_MUL expression
    {
        std::cout << "expression -> expression T_MUL expression" << std::endl;
    }
|
    expression T_DIV expression
    {
        std::cout << "expression -> expression T_DIV expression" << std::endl;
    }
|
    expression T_MOD expression
    {
        std::cout << "expression -> expression T_MOD expression" << std::endl;
    }
|
    expression T_LESS expression
    {
        std::cout << "expression -> expression T_LESS expression" << std::endl;
    }
|
    expression T_GR expression
    {
        std::cout << "expression -> expression T_GR expression" << std::endl;
    }
|
    expression T_EQ expression
    {
        std::cout << "expression -> expression T_EQ expression" << std::endl;
    }
|
    expression T_AND expression
    {
        std::cout << "expression -> expression T_AND expression" << std::endl;
    }
|
    expression T_OR expression
    {
        std::cout << "expression -> expression T_OR expression" << std::endl;
    }
|
    T_NOT expression
    {
        std::cout << "expression -> T_NOT expression" << std::endl;
    }
|
    T_OPEN expression T_CLOSE
    {
        std::cout << "expression -> T_OPEN expression T_CLOSE" << std::endl;
    }
;
