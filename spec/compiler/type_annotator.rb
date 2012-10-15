require 'compiler/type_annotator'
require 'schema/schema_manager'
require 'data/table_manager'
require 'errors/type_error'
require 'errors/symbol_error'
require 'ast/common/variable'
require 'ast/common/operator'
require 'schema/schema'
require 'schema/column'
require 'schema/expression_type'
require 'schema/storage_type'

include SquirrelDB
include Schema
include Data
include Compiler

decribe TypeAnnotator do
  
  before :each do
    @schema = Schema.new([
      Column.new(Variable.new("c1"), StorageType::SHORT),
      Column.new(Variable.new("c2"), StorageType::BOOLEAN),
      Column.new(Variable.new("c3"), StorageType::STRING, Constant.new("a", ExpressionType::STRING))
    ])
    @sm = mock(SchemaManager).stub!(:get).with(Variable.new("t")).and_return(@schema)
    @tm = mock(TableManager).stub!(:variable_id).with(Variable.new("t")).and_return(1)
    @ta = TypeAnnotator.new(@sm, @tm)
    @string = Constant.new("asdf", ExpressionType::STRING)
    @int = Constant.new(23, ExpressionType::INTEGER)
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

  it "should find out the correct type of a variable in a select clause" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("c1")),
      FromClause.new(Variable.new("t")),
      WhereClause::EMPTY
    )
    @ta.process(select).select_clause.should have_type(:integer)
  end
  
  it "should find out the correct type of a variable in a where clause" do
    select = SelectStatement.new(
      SelectClause.new(Variable.new("c1")),
      FromClause.new(Variable.new("t")),
      BinaryOperation.new(
        
      )
    )
    @ta.process(select).select_clause.should have_type(:integer)
  end

end