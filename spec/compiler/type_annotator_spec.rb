require 'compiler/type_annotator'
require 'schema/schema_manager'
require 'data/table_manager'
require 'errors/type_error'
require 'errors/symbol_error'
require 'ast/common/variable'
require 'ast/common/operator'
require 'schema/schema'
require 'ast/common/column'
require 'schema/expression_type'
require 'schema/storage_type'
require 'schema/function'
require 'schema/function_manager'

include SquirrelDB
include SquirrelDB::Schema
include SquirrelDB::Data
include SquirrelDB::Compiler

describe TypeAnnotator do
  
  before :each do
    @schema = Schema.new([
      Column.new(Variable.new("c1"), StorageType::SHORT),
      Column.new(Variable.new("c2"), StorageType::DOUBLE),
      Column.new(Variable.new("c3"), StorageType::STRING, Constant.new("a", ExpressionType::STRING))
    ])
    @sm = mock(SchemaManager).stub!(:get).with(Variable.new("t")).and_return(@schema)
    @tm = mock(TableManager).stub!(:variable_id).with(Variable.new("t")).and_return(1)
    @fm = FunctionManager.new(Function::BUILT_IN) # TODO use stub
    @ta = TypeAnnotator.new(@sm, @fm, @tm)
    @string = Constant.new("asdf", ExpressionType::STRING)
    @int = Constant.new(23, ExpressionType::INTEGER)
    @double = Constant.new(23, ExpressionType::INTEGER)
    @null = Constant::NULL
  end
  
  it "should raise an error if a string is divided by a string" do
    lambda do
      @ta.process(
        BinaryOperation.new(
          Operator::DIVIDED_BY,
          @string,
          @string
        )
      ) 
    end.should raise_error(SquirrelDB::TypeError)
  end
  
  it "should raise an error if a string is added to an integer" do
    lambda do
      @ta.process(
        BinaryOperation.new(
          Operator::PLUS,
          @string,
          @int
        )
      ) 
    end.should raise_error(SquirrelDB::TypeError)
  end
  
  it "should raise an error if a string is added to an integer" do
    lambda do
      @ta.process(
        BinaryOperation.new(
          Operator::PLUS,
          @string,
          @int
        )
      ) 
    end.should raise_error(SquirrelDB::TypeError)
  end

  it "should find out the correct type of int + int" do

    @ta.process(
      BinaryOperation.new(
        Operator::PLUS,
        @int,
        @int
      )
    ).should have_type(:integer)
  end

  it "should find out the correct type of int + double" do
    @ta.process(
      BinaryOperation.new(
        Operator::PLUS,
        @int,
        @double
      )
    ).should have_type(:integer)
  end

  it "should find out the correct type of int + null" do
    @ta.process(
      BinaryOperation.new(
        Operator::PLUS,
        @int,
        @null
      )
    ).should have_type(:integer)
  end
  
  it "should find out the correct type of a variable in a where clause" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("c1")),
      FromClause.new(Variable.new("t")),
      WhereClause::EMPTY
    )
    @ta.process(select).select_clause.first.should have_type(:integer)
  end
  
  it "should find out the correct type of a variable in a where clause" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("c1")),
      FromClause.new(Variable.new("t")),
      WhereClause.new(
        BinaryOperation.new(
          Operator::EQUALS,
          Variable.new("c3"),
          Constant.new("asdf", ExpressionType::STRING)
        )
      )
    )
    @ta.process(select).where_clause.expression.left.should have_type(:string)
  end

  it "should raise an error if the where clause does not return a boolean" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("c1")),
      FromClause.new(Variable.new("t")),
      Variable.new("c1")
    )
    lambda { @ta.process(select) }.should raise_error(TypeError)
  end
  
  it "should raise an error if an unknown variable appears in the select clause" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("lol")),
      FromClause.new(Variable.new("t")),
      WhereClause.new(Constant::TRUE)      
    )
    lambda { @ta.process(select) }.should raise_error(SymbolError)
  end
  
  it "should raise an error if an unknown variable appears in the where clause" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("c1")),
      FromClause.new(Variable.new("t")),
      WhereClause.new(Variable.new("bar"))      
    )
    lambda { @ta.process(select) }.should raise_error(SymbolError)
  end
  
  it "should raise an error if a default value doesn't match the type of a column in a create table" do
    select = CreateTable.new(
      Variable.new("table"),
      [
        Column.new(Variable.new("column"), StorageType::INTEGER, Constant::TRUE)
      ]
    )
    lambda { @ta.process(select) }.should raise_error(SquirrelDB::TypeError)
  end
   
  it "should accept a well-formed create table" do
    select = CreateTable.new(
      Variable.new("table"),
      [
        Column.new(Variable.new("column"), StorageType::SHORT, Constant.new(23, ExpressionTyoe::INTEGER)),
        Column.new(Variable.new("col"), StorageType::DOUBLE, Constant.new(23, ExpressionTyoe::INTEGER)),
        Column.new(Variable.new("c"), StorageType::STRING)
      ]
    )
    lambda { @ta.process(select) }.should_not raise_error
  end
   
  it "should not accept a create table with ambiguous column names" do
    select = CreateTable.new(
      Variable.new("table"),
      [
        Column.new(Variable.new("column"), StorageType::SHORT),
        Column.new(Variable.new("column"), StorageType::STRING)
      ]
    )
    lambda { @ta.process(select) }.should raise_error(SymbolError)
  end
   
  it "should accept an insert with fitting types" do
    select = Insert.new(
      Variable.new("t"),
      [
        Variable.new("c1"),
        Variable.new("c2"),
        Variable.new("c3")
      ],
      Values.new([
        Constant.new(3, ExpressionType::INTEGER),
        Constant.new(4.0, ExpressionType::DOUBLE),
        Constant.new("asdf", ExpressionType::STRING)
      ])
    )
    lambda { @ta.process(select) }.should_not raise_error
  end
   
  it "should accept an insert with convertable types" do
    select = Insert.new(
      Variable.new("t"),
      [
        Variable.new("c1"),
        Variable.new("c2"),
        Variable.new("c3")
      ],
      Values.new([
        Constant.new(3, ExpressionType::INTEGER),
        Constant.new(4, ExpressionType::INTEGER),
        Constant::NULL
      ])
    )
    lambda { @ta.process(select) }.should_not raise_error
  end
  
  it "should accept an insert with a fitting type with reordered columns" do
    select = Insert.new(
      Variable.new("t"),
      [
        Variable.new("c2"),
        Variable.new("c3"),
        Variable.new("c1")
      ],
      Values.new([
        Constant.new(3.0, ExpressionType::DOUBLE),
        Constant.new("asdf", ExpressionType::STRING),
        Constant.new(4, ExpressionType::INTEGER)
      ])
    )
    lambda { @ta.process(select) }.should_not raise_error
  end
  
  it "should not accept an insert if there are more columns than values" do
    select = Insert.new(
      Variable.new("t"),
      [
        Variable.new("c1"),
        Variable.new("c2"),
        Variable.new("c3")
      ],
      Values.new([
        Constant.new(3, ExpressionType::INTEGER),
        Constant.new(4.0, ExpressionType::DOUBLE)
      ])
    )
    lambda { @ta.process(select) }.should raise_error(TypeError)
  end  
    
  it "should not accept an insert if there are more values than columns" do
    select = Insert.new(
      Variable.new("t"),
      [
        Variable.new("c1")
      ],
      Values.new([
        Constant.new(3, ExpressionType::INTEGER),
        Constant.new(4.0, ExpressionType::DOUBLE)
      ])
    )
    lambda { @ta.process(select) }.should raise_error(TypeError)
  end
  
  it "should not accept an insert if there are more values than columns" do
    select = Insert.new(
      Variable.new("t"),
      [
        Variable.new("c1")
      ],
      Values.new([
        Constant.new(3, ExpressionType::INTEGER),
        Constant.new(4.0, ExpressionType::DOUBLE)
      ])
    )
    lambda { @ta.process(select) }.should raise_error(TypeError)
  end
  
end