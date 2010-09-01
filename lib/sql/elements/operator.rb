module RubyDB

  module Sql

    class Operator

      def initialize( symbol, cardinality,
          precedence=10, right_associative=false, *alternative_symbols )
        @symbol = symbol
        @cardinality = cardinality # binary or unary
        @precedence = precedence
        @right_associative = right_associative
        @alternative_symbols = alternative_symbols
      end

      attr_reader :symbol, :cardinality, :precedence

      include Comparable

      def right_associative?
        @right_associative
      end

      def to_s
        @symbol
      end

      def inspect
        @cardinality.to_s + " " + @symbol
      end

      def to_regexp
        @regexp ||= Regexp.union( @symbol, *@alternative_symbols )
      end

      def is_unary?
        @cardinality == :unary
      end

      def is_binary?
        @cardinality == :binary
      end

      def <=>(other)
        @precedence <=> other.precedence
      end

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
      ALL_OPERATORS = self.constants.collect { |c| self.const_get( c ) }

      def self.choose_unary_operator( symbol )
        op = ALL_OPERATORS.find { |op| symbol =~ op.to_regexp }
        raise "No unary Operation for #{symbol.inspect} found." unless op
        op
      end

      def self.choose_binary_operator( symbol )
        op = ALL_OPERATORS.find { |op| symbol =~ op.to_regexp }
        raise "No binary Operation for #{symbol.inspect} found." unless op
        op
      end

    end

  end

end
