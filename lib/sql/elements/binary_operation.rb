require 'sql/elements/syntactic_unit'

module RubyDB

  module Sql

    class BinaryOperation < SyntacticUnit
    
      def initialize( operator, left, right )
        @operator = operator
        @left = left
        @right = right
      end

      attr_reader :operator, :left, :right

      def ==(other)
        super && @operator == other.operator && @left == other.left && @right == other.right
      end

      def to_s
        "(" + @left.to_s + " " + @operator.to_s + " " + @right.to_s + ")"
      end

      def inspect
        "(" + @left.inspect + " " + @operator.to_s + " " + @right.inspect + ")"
      end

      def visit( visitor )
        let_visit( visitor, @operator, @left.visit( visitor ), @right.visit( visitor ) )
      end

    end

  end

end
