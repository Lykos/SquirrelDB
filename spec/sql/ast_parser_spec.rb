require 'sql/ast_parser.tab'
require 'ast/common/all'
require 'schema/expression_type'
require 'schema/storage_type'
require 'spec_helper'

include SquirrelDB
include SQL
include AST
include SquirrelDB::Schema

describe ASTParser do
  
  before :each do
    @parser = ASTParser.new
    @lexer = mock(Lexer)
    @parser.lexer = @lexer
  end
  
  def set_expr_tokens(*tokens)
    set_tokens(["select", "select"], *tokens)
  end
  
  def set_tokens(*tokens)
    tokens.each.with_object(@lexer.should_receive(:scan)) do |t, e|
      e.and_yield(t)
    end.and_yield([false, false])
  end
  
  it "should parse a boolean constant correctly" do
    set_expr_tokens([:BOOLEAN, "faLsE"])
    @parser.parse.should calculate_expression(Constant.new(false, ExpressionType::BOOLEAN))
  end
  
  it "should parse a string constant correctly" do
    set_expr_tokens([:STRING, "23"])
    @parser.parse.should calculate_expression(Constant.new("23", ExpressionType::STRING))
  end
  
  it "should parse a double constant correctly" do
    set_expr_tokens([:DOUBLE, "2.3"])
    @parser.parse.should calculate_expression(Constant.new(2.3, ExpressionType::DOUBLE))
  end
  
  it "should parse an integer constant correctly" do
    set_expr_tokens([:INTEGER, "23"])
    @parser.parse.should calculate_expression(Constant.new(23, ExpressionType::INTEGER))
  end
  
  it "should parse an expression enclosed with brackets correctly" do
    set_expr_tokens(
      ["(", "("],
      [:INTEGER, "22"],
      [")", ")"]
    )
    @parser.parse.should calculate_expression(Constant.new(22, ExpressionType::INTEGER))
  end
  
  it "should parse a variable correctly" do
    set_expr_tokens([:IDENTIFIER, "a"])
    @parser.parse.should calculate_expression(Variable.new("a"))
  end
  
  it "should parse a scoped variable correctly" do
    set_expr_tokens(
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "b"]
    )
    @parser.parse.should calculate_expression(
      ScopedVariable.new(
        Variable.new("a"),
        Variable.new("b")
      )
    )
  end
  
  it "should parse a scoped scoped variable correctly" do
    set_expr_tokens(
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "b"],
      [".", "."],
      [:IDENTIFIER, "c"]
    )
    @parser.parse.should calculate_expression(
      ScopedVariable.new(
        ScopedVariable.new(
          Variable.new("a"),
          Variable.new("b")
        ),
        Variable.new("c")
      )
    )
  end
  
  it "should parse a function application with no arguments correctly" do
    set_expr_tokens([:IDENTIFIER, "a"], ["(", "("], [")", ")"])
    @parser.parse.should calculate_expression(FunctionApplication.new(Variable.new("a"), []))
  end
  
  it "should parse a function application with one argument correctly" do
    set_expr_tokens(
      [:IDENTIFIER, "a"],
      ["(", "("],
      [:INTEGER, "22"],
      [")", ")"]
    )
    @parser.parse.should calculate_expression(
      FunctionApplication.new(
        Variable.new("a"),
        [Constant.new(22, ExpressionType::INTEGER)]
      )
    )
  end
  
  
  it "should parse a function application with one argument and a scoped scoped name correctly" do
    set_expr_tokens(
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "b"],
      [".", "."],
      [:IDENTIFIER, "c"],
      ["(", "("],
      [:INTEGER, "22"],
      [")", ")"]
    )
    @parser.parse.should calculate_expression(
      FunctionApplication.new(
        ScopedVariable.new(
          ScopedVariable.new(
            Variable.new("a"),
            Variable.new("b")
          ),
          Variable.new("c")
        ),
        [Constant.new(22, ExpressionType::INTEGER)]
      )
    )
  end

  it "should parse a function application with several arguments correctly" do
    set_expr_tokens(
      [:IDENTIFIER, "a"],
      ["(", "("],
      [:INTEGER, "22"],
      [",", ","],
      [:INTEGER, "23"],
      [",", ","],
      [:INTEGER, "24"],
      [")", ")"]
    )
    @parser.parse.should calculate_expression(
      FunctionApplication.new(
        Variable.new("a"),
        [
          Constant.new(22, ExpressionType::INTEGER),
          Constant.new(23, ExpressionType::INTEGER),
          Constant.new(24, ExpressionType::INTEGER)
        ]
      )
    )
  end
  
  it "should parse a unary operation correctly" do
    set_expr_tokens(
      ["+", "+"],
      [:INTEGER, "22"]
    )
    @parser.parse.should calculate_expression(
      UnaryOperation.new(
        Operator::UNARY_PLUS,
        Constant.new(22, ExpressionType::INTEGER)
      )
    )
  end
  
  it "should parse a binary operation correctly" do
    set_expr_tokens(
      [:INTEGER, "23"],
      ["+", "+"],
      [:INTEGER, "22"]
    )
    @parser.parse.should calculate_expression(
      BinaryOperation.new(
        Operator::PLUS,
        Constant.new(23, ExpressionType::INTEGER),
        Constant.new(22, ExpressionType::INTEGER)
      )
    )
  end
  
  it "should parse several right associative binary operations correctly" do
    set_expr_tokens(
      [:INTEGER, "23"],
      ["**", "**"],
      [:INTEGER, "22"],
      ["**", "**"],
      [:INTEGER, "22"],
      ["**", "**"],
      [:INTEGER, "21"]
    )
    @parser.parse.should calculate_expression(
      BinaryOperation.new(
        Operator::POWER,
        Constant.new(23, ExpressionType::INTEGER),
        BinaryOperation.new(
          Operator::POWER,
          Constant.new(22, ExpressionType::INTEGER),
          BinaryOperation.new(
            Operator::POWER,
            Constant.new(22, ExpressionType::INTEGER),
            Constant.new(21, ExpressionType::INTEGER)
          )
        )
      )
    )
  end
  
  it "should parse several binary operations with the same precedence correctly" do
    set_expr_tokens(
      [:INTEGER, "23"],
      ["+", "+"],
      [:INTEGER, "22"],
      ["+", "+"],
      [:INTEGER, "22"],
      ["-", "-"],
      [:INTEGER, "21"]
    )
    @parser.parse.should calculate_expression(
      BinaryOperation.new(
        Operator::MINUS,
        BinaryOperation.new(
          Operator::PLUS,
          BinaryOperation.new(
            Operator::PLUS,
            Constant.new(23, ExpressionType::INTEGER),
            Constant.new(22, ExpressionType::INTEGER)
          ),
          Constant.new(22, ExpressionType::INTEGER)
        ),
        Constant.new(21, ExpressionType::INTEGER)
      )
    )
  end
  
  it "should respect precedences of binary operations" do
    set_expr_tokens(
      [:INTEGER, "23"],
      ["+", "+"],
      [:INTEGER, "22"],
      ["*", "*"],
      [:INTEGER, "21"]
    )
    @parser.parse.should calculate_expression(
      BinaryOperation.new(
        Operator::PLUS,
        Constant.new(23, ExpressionType::INTEGER),
        BinaryOperation.new(
          Operator::TIMES,
          Constant.new(22, ExpressionType::INTEGER),
          Constant.new(21, ExpressionType::INTEGER)
        )
      )
    )   
  end
  
  it "should override precedences of binary operations by brackets" do
    set_expr_tokens(
      ["(", "("],
      [:INTEGER, "23"],
      ["+", "+"],
      [:INTEGER, "22"],
      [")", ")"],
      ["*", "*"],
      [:INTEGER, "21"]
    )
    @parser.parse.should calculate_expression(
      BinaryOperation.new(
        Operator::TIMES,
        BinaryOperation.new(
          Operator::PLUS,
          Constant.new(23, ExpressionType::INTEGER),
          Constant.new(22, ExpressionType::INTEGER)
        ),
        Constant.new(21, ExpressionType::INTEGER)
      )
    )   
  end
  
  it "should respect precedences of unary operations" do
    set_expr_tokens(
      ["+", "+"],
      ["~", "~"],
      [:INTEGER, "22"],
      ["**", "**"],
      [:INTEGER, "21"]
    )
    @parser.parse.should calculate_expression(
      UnaryOperation.new(
        Operator::UNARY_PLUS,
        BinaryOperation.new(
          Operator::POWER,
          UnaryOperation.new(
            Operator::BIT_NOT,
            Constant.new(22, ExpressionType::INTEGER)
          ),
          Constant.new(21, ExpressionType::INTEGER)
        )
      )
    )   
  end
  
  it "should override precedences of unary operations by brackets" do
    set_expr_tokens(
      ["(", "("],
      ["+", "+"],
      ["~", "~"],
      [:INTEGER, "22"],
      [")", ")"],
      ["**", "**"],
      [:INTEGER, "21"]
    )
    @parser.parse.should calculate_expression(
      BinaryOperation.new(
        Operator::POWER,
        UnaryOperation.new(
          Operator::UNARY_PLUS,
          UnaryOperation.new(
            Operator::BIT_NOT,
            Constant.new(22, ExpressionType::INTEGER)
          )
        ),
        Constant.new(21, ExpressionType::INTEGER)
      )
    )   
  end
  
  it "should parse a select statement correctly" do
    set_tokens(
      ["select", "select"],
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "a"],
      ["as", "as"],
      [:IDENTIFIER, "b"],
      [",", ","],
      [:IDENTIFIER, "lol"],
      ["from", "from"],
      [:IDENTIFIER, "t1"],
      ["as", "as"],
      [:IDENTIFIER, "buu"],
      [",", ","],
      [:IDENTIFIER, "t2"],
      ["where", "where"],
      [:IDENTIFIER, "i"],
      ["=", "="],
      [:IDENTIFIER, "bui"]
    )
    @parser.parse.should eq(
      SelectStatement.new(
        SelectClause.new([
          Renaming.new(
            ScopedVariable.new(Variable.new("a"), Variable.new("a")),
            Variable.new("b")
          ),
          Variable.new("lol")
        ]),
        FromClause.new([
          Renaming.new(Variable.new("t1"), Variable.new("buu")),
          Variable.new("t2")
        ]),
        WhereClause.new(
          BinaryOperation.new(
            Operator::EQUAL,
            Variable.new("i"),
            Variable.new("bui")
          )
        )
      )
    )
  end
  
  it "should parse an insert statement correctly" do
    set_tokens(
      ["insert", "insert"],
      ["into", "into"],
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "b"],
      ["(", "("],
      [:IDENTIFIER, "c"],
      [",", ","],
      [:IDENTIFIER, "d"],
      [")", ")"],
      ["values", "values"],
      ["(", "("],
      [:INTEGER, "2"],
      [",", ","],
      [:INTEGER, "3"],
      [")", ")"]
    )
    @parser.parse.should eq(
      Insert.new(
        ScopedVariable.new(
          Variable.new("a"),
          Variable.new("b")
        ),
        [
          Variable.new("c"),
          Variable.new("d")
        ],
        Values.new([
          Constant.new(2, ExpressionType::INTEGER),
          Constant.new(3, ExpressionType::INTEGER)
        ])
      )
    )
  end
  
  it "should parse a create table statement correclty" do
    set_tokens(
      ["create", "create"],
      ["table", "table"],
      [:IDENTIFIER, "a"],
      [".", "."],
      [:IDENTIFIER, "b"],
      ["(", "("],
      [:IDENTIFIER, "c"],
      [:IDENTIFIER, "integer"],
      ["default", "default"],
      [:INTEGER, "3"],
      [",", ","],
      [:IDENTIFIER, "d"],
      [:IDENTIFIER, "StrIng"],
      [")", ")"]
    )
    @parser.parse.should eq(
      CreateTable.new(
        ScopedVariable.new(
          Variable.new("a"),
          Variable.new("b")
        ),
        [
          Column.new("c", StorageType::INTEGER, Constant.new(3, ExpressionType::INTEGER)),
          Column.new("d", StorageType::STRING)
        ],
      )
    )  
  end
  
end