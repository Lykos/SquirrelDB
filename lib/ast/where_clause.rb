require 'ast/syntactic_unit'

module SquirrelDB

  module AST

    class WhereClause < SyntacticUnit

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

      def accept( visitor )
        let_visit( visitor, @expression.accept( visitor ) )
      end

    end

  end
  
end
