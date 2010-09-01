require 'sql/parser/syntactic_parser'
require 'sql/elements/operator'
require 'sql/elements/type'

include RubyDB
include Sql

describe SyntacticParser do

  before(:each) do
    @syntactic_parser = SyntacticParser.new
  end

  it "should parse a select with a complex arithmetic expresion correctly" do
    @syntactic_parser.parse( "select 2 * 3 + (-4) * 3 + (2 / -3 - 1 + --(4*zebra)) * f(3)" ).should == SelectStatement.new(
      SelectClause.new( [
        Renaming.new(
          BinaryOperation.new(
            Operator::PLUS,
            BinaryOperation.new(
              BinaryOperation.new(
                Operator::PLUS,
                BinaryOperation.new(
                  Operator::TIMES,
                  Constant.new( 2, Type::INTEGER ),
                  Constant.new( 3, Type::INTEGER )
                ),
                BinaryOperation.new(
                  Operator::TIMES,
                  UnaryOperation.new(
                    Operator::UNARY_MINUS,
                    Constant.new( 4, Type::INTEGER )
                  ),
                  Constant.new( 4, Type::INTEGER )
                )
              )
            ),
            BinaryOparation.new(
              Operator::TIMES,
              BinaryOperation.new(
                Operator::PLUS,
                BinaryOperation.new(
                  Operator::MINUS,
                  BinaryOperation.new(
                    Operator::DIVIDED,
                    Constant.new( 2, Type::INTEGER ),
                    UnaryOperation.new(
                      Type::UNARY_MINUS,
                      Constant.new( 3, Type::INTEGER )
                    )
                  ),
                  Constant.new( 1, Type::INTEGER )
                ),
                UnaryOperation.new(
                  Operator::UNARY_MINUS,
                  UnaryOperation.new(
                    Operator::UNARY_MINUS(
                      BinaryOperation.new(
                        Operator::TIMES,
                        Constant.new( 4, Type::INTEGER ),
                        Variable.new( "zebra" )
                      )
                    )
                  )
                )
              ),
              FunctionApplication.new(
                Variable.new( "f" ),
                Constant.new( 3, Type::INTEGER )
              )
            )
          )
        )
      ] ),
      FromClause.new( [] ),
      WhereClause.new( Constant.new( true, Type::BOOLEAN ) )
    )
  end

  it "should parse * before + correctly" do
    @syntactic_parser.parse( "select 2 + b * a" ).should = SelectStatement.new(
      SelectClause.new( [
        Renaming.new(
          BinaryOperation.new(
            Operator::PLUS,
            Constant.new( 2, Type::INTEGER ),
            BinaryOperation.new(
              Operator::TIMES,
              Variable.new( "a" ),
              Variable.new( "b" )
            )
          )
        )
      ] )
    )
  end

  it "should parse a select with a ** correctly" do
    @syntactic_parser.parse( "select 2 ** 3" ).should == SelectStatement.new(
      SelectClause.new( [
        Renaming.new(
          BinaryOperation.new(
            Constant.new( 2, Type::INTEGER ),
            Operator::POWER,
            Constant.new( 3, Type::INTEGER )
          )
        )
      ] ),
      FromClause.new( [] ),
      WhereClause.new( Constant.new( true, Type::BOOLEAN ) )
    )
  end

end

