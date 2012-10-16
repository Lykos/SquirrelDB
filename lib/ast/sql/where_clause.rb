require 'ast/common/element'
require 'ast/common/constant'

module SquirrelDB

  module AST

    class WhereClause < Element

      def initialize(expression)
        @expression = expression
      end
    
      attr_reader :expression
      
      EMPTY = WhereClause.new(Constant::TRUE)

      def to_s
        "where " + @expression.to_s
      end

      def inspect
        "WhereClause( " + @expression.inspect + " )"
      end

      def ==(other)
        super && @expression == other.expression
      end
      
      def hash
        @hash ||= [super, @expression].hash
      end

    end
    
    def where(expression)
      WhereClause.new(expression)
    end

  end
  
end
