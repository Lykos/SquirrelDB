require 'eregex'

module Sql

  class Operator

    def initialize( symbol, type, precedence=10, right_associative=false, *alternative_symbols )
      @symbol = symbol
      @type = type # binary or unary
      @precedence = precedence
      @right_associative = right_associative
      @alternative_symbols = alternative_symbols
    end

    attr_reader :symbol, :type, :right_associative, :precedence

    include Comparable

    def to_s
      @symbol
    end

    def inspect
      @type.to_s + " " + @symbol
    end

    def to_regexp
      @regexp ||= Regexp.union( @symbol, *@alternative_symbols )
    end

    def is_unary?
      @type == :unary
    end

    def is_binary?
      @type == :binary
    end

    def <=>(other)
      @precedence <=> other.precedence
    end

  end

end
