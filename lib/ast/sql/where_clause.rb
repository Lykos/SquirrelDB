require 'ast/common/element'

module SquirrelDB

  module AST

    class WhereClause < Element

      def initialize(expression)
        @expression = expression
      end
    
      attr_reader :expression

      def to_s
        "where " + @expression.to_s
      end

      def inspect
        "WhereClause( " + @expression.inspect + " )"
      end

      def ==(other)
        super && @expression == other.expression
      end

    end

  end
  
end
