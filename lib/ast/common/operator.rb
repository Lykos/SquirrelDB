require 'ast/common/variable'
require 'errors/internal_error'

module SquirrelDB

  module AST

    class Operator < Variable
      
      CARDINALITIES = [:binary, :unary]
      ALL_OPERATORS = []
      
      protected
      
      def self.new(*args)
        super
      end
      
      def initialize(symbol, cardinality, *alternative_symbols)
        super(symbol)
        unless CARDINALITIES.include?(cardinality)
          raise InternalError, "Invalid cardinality #{cardinality}. Only #{CARDINALITIES.join(", ")} are supported."
        end
        @cardinality = cardinality
        @alternative_symbols = alternative_symbols
        ALL_OPERATORS << self
      end
      
      public

      alias symbol :name

      attr_reader :cardinality, :alternative_symbols

      def to_s
        symbol
      end

      def inspect
        @cardinality.to_s + " " + symbol
      end

      def pattern
        @pattern ||= Regexp.union(([symbol] + @alternative_symbols).collect { |s| Regexp.new(Regexp.escape(s), Regexp::IGNORECASE) })
      end

      def unary?
        @cardinality == :unary
      end

      def binary?
        @cardinality == :binary
      end
      
      def hash
        @hash ||= [super, @cardinality, @alternative_symbols].hash
      end

      def ==(other)
        super && @cardinality == other.cardinality && @alternative_symbols == other.alternative_symbols
      end

      # All operators ordered in the order they are parsed, i.e. ** has to appear before *. But this has nothing to do with the precedence
      # only with the symbols which are a prefix of other symbols.

      POWER = Operator.new('**', :binary)
      UNARY_PLUS = Operator.new('+', :unary)
      UNARY_MINUS = Operator.new('-', :unary)
      BIT_NOT = Operator.new('~', :unary)
      NOT = Operator.new('!', :unary, 'NOT')
      TIMES = Operator.new('*', :binary)
      DIVIDED_BY = Operator.new('/', :binary)
      MODULO = Operator.new('%', :binary)
      PLUS = Operator.new('+', :binary)
      MINUS = Operator.new('-', :binary)
      AND = Operator.new('&&', :binary, 'AND')
      XOR = Operator.new('^^', :binary, 'XOR')
      OR = Operator.new('||', :binary, 'OR')
      EQUIVALENT = Operator.new('<->', :binary, 'EQUIVALENT')
      IMPLIES = Operator.new('->', :binary, 'IMPLIES')
      IS_IMPLIED = Operator.new('<-', :binary)
      LEFT_SHIFT = Operator.new('<<', :binary)
      RIGHT_SHIFT = Operator.new('>>', :binary)
      BIT_AND = Operator.new('&', :binary)
      BIT_XOR = Operator.new('^', :binary)
      BIT_OR = Operator.new('|', :binary)
      GREATER = Operator.new('>', :binary)
      GREATER_EQUAL = Operator.new('>=', :binary)
      SMALLER = Operator.new('<', :binary)
      SMALLER_EQUAL = Operator.new('<=', :binary)
      EQUALS = Operator.new('=', :binary)
      NOT_EQUALS = Operator.new('!=', :binary)
      
      UNARY_OPERATORS = ALL_OPERATORS.select { |o| o.unary? }
      BINARY_OPERATORS = ALL_OPERATORS.select { |o| o.binary? }

      def self.unary_operator(symbol)
        @@unary_operators[symbol] ||= choose_unary_operator(symbol)
      end
      
      def self.binary_operator(symbol)
        @@binary_operators[symbol] ||= choose_binary_operator(symbol)
      end

      protected
      
      @@unary_operators = {}
      @@binary_operators = {}
      
      def self.choose_unary_operator(symbol)
        op = UNARY_OPERATORS.find { |o| symbol =~ o.pattern }
        raise InternalError, "No unary Operation for #{symbol.inspect} found." unless op
        op
      end

      def self.choose_binary_operator(symbol)
        op = BINARY_OPERATORS.find { |o| symbol =~ o.pattern }
        raise InternalError, "No binary Operation for #{symbol.inspect} found." unless op
        op
      end
      
      private
      
      def new(*args)
        super
      end

    end

  end

end
