class SquirrelDB::SQL::ASTParser
  prechigh
    right "."
    nonassoc "~"
    right "**"
    nonassoc UMINUS UPLUS
    left "*" "/" "%"
    left "+" "-"
    left "<<" ">>"
    left "&"
    left "^"
    left "|"
    nonassoc "!"
    left "<=" "<" ">=" ">"
    left "=" "!="
    left "&&"
    left "^^"
    left "||"
    right "->"
    left "<-"
    left "<->"
  preclow
  options no_result_var
  start statement
  rule
    statement: select
             | insert
             | update
             | delete
             | create_scope
             | create_table
             | create_view
             | drop_scope
             | drop_table
             | drop_view
             | grant
             
    select: select_clause from_clause where_clause
                      { SelectStatement.new(val[0], val[1], val[2]) }
             
    select_clause: "select" columns
                   { SelectClause.new(val[1]) }
             
    columns: renamed_column
             { val }
           | renamed_column "," columns
             { [val[0]].concat(val[2]) }
             
    renamed_column: column
                  | column "as" variable
                    { Renaming.new(val[0], val[2]) }
                    
    column: expression
          | wildcard
          
    wildcard: "*"
              { WildCard.new }
            | name "." "*"
              { ScopedVariable.new(val[0], WildCard.new) }
              
    from_clause: { FromClause.new([]) }
               | "from" tables { FromClause.new(val[1]) }
               
    tables: renamed_table
            { val }
          | renamed_table "," tables
            { [val[0]].concat(val[2]) }
          
    renamed_table: table
                 | table "as" variable
                   { Renaming.new(val[0], val[2]) }
                   
    table: "(" select ")" { val[1] }
         | name
         
    where_clause: { WhereClause::EMPTY }
                | "where" expression
                  { WhereClause.new(val[1]) }
                 
    insert: "insert" "into" name "(" insert_columns ")" insert_values
            { Insert.new(val[2], val[4], val[6]) }
    
    insert_columns: variable
                    { val }
                  | variable "," insert_columns
                    { [val[0]].concat(val[2]) }
                    
    insert_values: select
                 | "values" "(" expressions ")"
                   { Values.new(val[2]) }
                   
    expressions: expression
                 { val }
               | expression "," expressions
                 { [val[0]].concat(val[2]) }
              
    update: "update" renamed_table "set" assignments where_clause
            { Update.new(renamed_table, assignments, where_clause) }
            
    assignments: assignment
                 { val }
               | assignment "," assignments
                 { [val[0]].concat(val[2]) }
                 
    assignment: variable "=" expression
                { Assignment.new(val[0], val[2]) }
                
    delete: "delete" "from" tables where_clause
            { Delete.new(val[2], val[3]) }
            
    create_scope: "create" "scope" name
                  { CreateScope.new(val[2]) }
                  
    create_table: "create" "table" name "(" schema_columns ")"
                  { CreateTable.new(val[2], val[4]) }
                | "create" "table" name "as" select
                  { CreateTableAs.new(val[2], val[4]) }
                  
    schema_columns: schema_column
                    { val }
                  | schema_column "," schema_columns
                    { [val[0]].concat(val[2]) }
                    
    schema_column: IDENTIFIER type default_value
                   { val[2] ? Column.new(val[0], val[1], val[2]) : Column.new(val[0], val[1]) }
                                       
    type: IDENTIFIER
          { StorageType.by_name(val[0].downcase) }
                    
    default_value: { nil }
                 | "default" constant
                   { val[1] }
                                           
    create_view: "create" "view" name "as" select
                 { CreateView.new(val[2], val[4]) }
                 
    drop_scope: "drop" "scope" name
                { DropScope.new(val[2]) }
                
    drop_table: "drop" "table" name
                { DropTable.new(val[2]) }
                
    drop_view: "drop" "view" name
                { DropView.new(val[2]) }
                
    grant: "grant" variable "on" name "to" variable
           { Grant.new(val[1], val[3], val[5]) }
           
    expression: "(" select ")" { val[1] }
              | function_application
              | "(" expression ")" { val[1] }
              | bracket_expression
              | binary_operation
              | unary_operation
              | name
              | constant
              
    binary_operation: expression "**" expression  { binop(val) } 
                    | expression "*" expression  { binop(val) } 
                    | expression "/" expression  { binop(val) } 
                    | expression "%" expression  { binop(val) } 
                    | expression "+" expression  { binop(val) } 
                    | expression "-" expression  { binop(val) } 
                    | expression "<<" expression  { binop(val) } 
                    | expression ">>" expression  { binop(val) } 
                    | expression "&" expression  { binop(val) } 
                    | expression "^" expression  { binop(val) } 
                    | expression "|" expression  { binop(val) } 
                    | expression "<=" expression  { binop(val) } 
                    | expression "<" expression  { binop(val) } 
                    | expression ">=" expression  { binop(val) } 
                    | expression ">" expression  { binop(val) } 
                    | expression "=" expression  { binop(val) } 
                    | expression "!=" expression  { binop(val) } 
                    | expression "&&" expression  { binop(val) } 
                    | expression "^^" expression  { binop(val) } 
                    | expression "||" expression  { binop(val) } 
                    | expression "->" expression  { binop(val) } 
                    | expression "<-" expression  { binop(val) } 
                    | expression "<->" expression  { binop(val) } 
                    
    unary_operation: "~" expression { unop(val) }
                   | "-" expression = UMINUS { unop(val) } 
                   | "+" expression = UPLUS { unop(val) } 
                   | "!" expression { unop(val) } 
                   
    function_application: name "(" arguments ")"
                          { funapp(val) }
                          
    arguments: { [] }
             | expression { [val[0]] }
             | expression "," arguments { [val[0]].concat(val[2]) }
             
    name: variable
        | scoped_variable
                         
    scoped_variable: name "." variable
                     { ScopedVariable.new(val[0], val[2]) }
                     
    variable: IDENTIFIER
              { Variable.new(val[0]) }
              
    constant: integer_constant
            | string_constant
            | double_constant
            | boolean_constant
            | null
              { Constant.new(nil, ExpressionType::NULL) }
            
    integer_constant: INTEGER
                      { Constant.new(val[0].to_i, ExpressionType::INTEGER) }
                      
    string_constant: STRING
                     { Constant.new(val[0][1..-2], ExpressionType::STRING) }
                     
    boolean_constant: BOOLEAN
                     {
                       value = case val[0].downcase
                       when "true"
                         true
                       when "false"
                         false
                       else
                         raise InternalError, "Unknown boolean value #{val[0]}."
                       end
                       Constant.new(value, ExpressionType::BOOLEAN)
                     }
                     
    double_constant: DOUBLE
                     { Constant.new(val[0].to_f, ExpressionType::DOUBLE) }
end

---- header
require 'ast/common/all'
require 'ast/sql/all'
require 'errors/internal_error'
require 'errors/parse_error'
require 'schema/expression_type'
require 'schema/storage_type'

include SquirrelDB::Schema
include SquirrelDB::AST

---- inner
attr_writer :lexer

def parse
  begin
    yyparse @lexer, :scan
  rescue Racc::ParseError => e
    raise SquirrelDB::ParseError, e.message
  end
end

def binop(val)
  BinaryOperation.new(Operator::choose_binary_operator(val[1]), val[0], val[2])
end

def unop(val)
  UnaryOperation.new(Operator::choose_unary_operator(val[0]), val[1])
end

def funapp(val)
  FunctionApplication.new(val[0], val[2])
end
