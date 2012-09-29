require 'ast/common/element'

module SquirrelDB

  module AST

    class Operator < Element
      
      CARDINALITIES = [:binary, :unary]

      def initialize( symbol, cardinality,
          precedence=10, right_associative=false, alternative_symbols=[] )
        unless CARDINALITIES.include?(cardinality)
          raise "Invalid cardinality #{cardinality}. Only #{CARDINALITIES.join(", ")} are supported."
        end
        @symbol = symbol
        @cardinality = cardinality
        @precedence = precedence
        @right_associative = right_associative
        @alternative_symbols = alternative_symbols
      end

      attr_reader :symbol, :cardinality, :precedence

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

      def unary?
        @cardinality == :unary
      end

      def binary?
        @cardinality == :binary
      end
      
      def hash
        @hash ||= [super, @symbol, @cardinality].hash
      end

      def ==(other)
        super && @symbol == other.symbol && @cardinality == other.cardinality
      end

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
      OR = Operator.new( '||', :binary, 30, false, ['OR'] )
      XOR = Operator.new( '^', :binary, 40, false, ['XOR'] )
      AND = Operator.new( '&&', :binary, 50, false, ['AND'] )
      IMPLIES = Operator.new( '->', :binary, 20, true, ['IMPLIES'] )
      IS_IMPLIED = Operator.new( '<-', :binary, 20 )
      EQUIVALENT = Operator.new( '<->', :binary, 10, false, ['EQUIVALENT'] )
      UNARY_PLUS = Operator.new( '+', :unary, 110 )
      UNARY_MINUS = Operator.new( '-', :unary, 110 )
      NOT = Operator.new( '!', :unary, 60, ['NOT'] )
      ALL_OPERATORS = [PLUS, MINUS, TIMES, DIVIDED_BY, MODULO, POWER, EQUAL, UNEQUAL, GREATER,
        GREATER_EQUAL, SMALLER, SMALLER_EQUAL, OR, XOR, AND, IMPLIES, IS_IMPLIED, EQUIVALENT,
        UNARY_PLUS, UNARY_MINUS, NOT]

      def self.choose_unary_operator( symbol )
        op = ALL_OPERATORS.find { |o| symbol =~ o.to_regexp and o.is_unary? }
        raise "No unary Operation for #{symbol.inspect} found." unless op
        op
      end

      def self.choose_binary_operator( symbol )
        op = ALL_OPERATORS.find { |o| symbol =~ o.to_regexp and o.is_binary? }
        raise "No binary Operation for #{symbol.inspect} found." unless op
        op
      end

    end

  end

end