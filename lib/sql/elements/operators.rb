require 'operator'

module Sql

  module Operators

    DOT = Operator.new( '.', :binary, 200 )
    PLUS = Operator.new( '+', :binary, 90 )
    MINUS = Operator.new( '-', :binary, 90 )
    TIMES = Operator.new( '*', :binary, 100 )
    DIVIDED_BY = Operator.new( '/', :binary, 100 )
    MODULO = Operator.new( '/', :binary, 100 )
    POWER = Operator.new( '**', :binary, 120, true )
    EQUAL = Operator.new( '=', :binary, 70 )
    UNEQUAL = Operator.new( '!=', :binary, 70 )
    GREATER = Operator.new( '>', :binary, 80 )
    GREATER_EQUAL = Operator.new( '>=', :binary, 80 )
    SMALLER = Operator.new( '<', :binary, 80 )
    SMALLER_EQUAL = Operator.new( '<=', :binary, 80 )
    OR = Operator.new( '||', :binary, 30 )
    XOR = Operator.new( '^', :binary, 40 )
    AND = Operator.new( '&&', :binary, 50 )
    IMPLIES = Operator.new( '->', :binary, 20, true )
    IS_IMPLIED = Operator.new( '<-', :binary, 20 )
    EQUIVALENT = Operator.new( '<->', :binary, 10 )
    UNARY_PLUS = Operator.new( '+', :unary, 110 )
    UNARY_MINUS = Operator.new( '-', :unary, 110 )
    NOT = Operator.new( '!', :unary, 60 )
    ALL_OPERATORS = [
      POWER, PLUS, MINUS, TIMES, DIVIDED_BY, EQUAL, UNEQUAL, GREATER,
      GREATER_EQUAL, SMALLER, SMALLER_EQUAL, OR, XOR, AND, IMPLIES, IS_IMPLIED,
      EQUIVALENT, UNARY_PLUS, UNARY_MINUS, NOT
    ]

    def self.choose_unary_operator( symbol )
      ALL_OPERATORS.find { |op| symbol =~ op.to_regexp }
    end

    def self.choose_binary_operator( symbol )
      ALL_OPERATORS.find { |op| symbol =~ op.to_regexp }
    end

    SELECT = Operator.new( 's', :binary, 0 )
    PROJECT = Operator.new( 'p', :binary, 0 )
    RENAME = Operator.new( 'r', :binary, 0 )
    CARTESIAN = Operator.new( 'x', :binary, 0 )

  end

end
